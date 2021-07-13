% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

%% EVALUATESEPARATION
% Function which evaluates signal separation performance for a particular value of tuple (alphaIndex, frameLen, setIndex)

% Inputs:
% outputDirectory: string path to directory where separated signal data (i.e. "outputA" and "outputB" files) is stored
% alphaIndex: alphaIndex being evaluated
% frameLen: frame length being evaluated
% setIndex: set index being evaluated
% nSources: number of sources to find
% params: SOI parameters to use

% Outputs:
% frameSuccessRate: performance metric indicating the fraction of frames that were decoded successfully after signal separation
% ber: (for informational purposes only): overall bit-error-rate after signal separation

function [frameSuccessRate, ber] = evaluateSeparation(outputDirectory, alphaIndex, frameLen, setIndex, nSources, params)

%% Input Error Checking
minValAlpha=1; maxValAlpha=25; validateInput(alphaIndex, minValAlpha, maxValAlpha,'alphaIndex');
minValFrameLen=1; maxValFrameLen=128; validateInput(frameLen, minValFrameLen, maxValFrameLen, 'frameLen');
minValSetIndex=1; maxValSetIndex=20; validateInput(setIndex, minValSetIndex, maxValSetIndex, 'setIndex');

%% Misc Setup and Parameters
nwords = frameLen;
plotFlag = false; % set to "true" to see constellation plot sample, "false" otherwise

% Load file "params.mat" containing waveform/coding parameters
%load('params.mat', 'params') 

load 'pulseShaping.mat' gRRC

nR = params.nR; % get the number of receive antennas

M = params.M;                           % modulation order
m = params.m;                           % BCH coding parameter "m"
n = params.n;                           % Codeword length
k = params.k;                           % Message length
t = params.t;                           % Number of correctable errors

nPreambleBits = params.nPreambleBits;   % Number of bits in preamble

sps = params.sps;                       % samples per symbol in modulated waveform
spanSyms = params.spanSyms;             % span of RRC filter (in syms)
rolloffFactor = params.rolloffFactor;   % root-raised-cosine filter rolloff factor
txSymsPreamble = params.txSymsPreamble; % number of symbols in preamble

noisePwr = params.noisePwr;             % noise power
nFrames = params.nFrames;               % number of frames per example

nOutputs = 1;                           % number of channels in separation output

suffixStr = {'A', 'B'};                 % initialize the suffix characters for the two separated output files

% initialize file read/write parameters
inputStruct.sample_rate = 25e6;
inputStruct.description = 'separatedSignals';
inputStruct.Nr = nR;
        
% loop over the number of frames 
for ff = 1:nFrames

    for cc = 1:nSources % loop through the two separated output files (i.e. "outputA" and "outputB")
      
        % get the appropriate suffix "A" or "B" for the current separated output being considered
        currSuffix = suffixStr{cc}; 
        
        % identify the separated output file to load
        separatedFilename = [outputDirectory, filesep, 'output', currSuffix, '_frameLen_', num2str(frameLen), '_setIndex_', num2str(setIndex), '_alphaIndex_', num2str(alphaIndex), '_frame', num2str(ff)];
        
        % load the separated output file
        Y0 = readData_oct(separatedFilename, 1, 'iqdata');

        %% Perform matched filtering with root-raised-cosine filtering
        Y = conv(Y0(1, :), gRRC, 'same');
        
        %% Downsample to Nyquist
        rxSyms = Y(:, sps:sps:end);
        
        %% Determine number of preamble symbols
        nSymsPreamble = nPreambleBits./log2(M);
        
        %% Extract the preamble
        rxSymsPreamble = rxSyms(:, 1:nSymsPreamble);
        
        %% Obtain Channel Estimate Hest by integrating over preamble symbols for each Rx antenna
        hratio = rxSymsPreamble ./ repmat(txSymsPreamble, nOutputs, 1);
        Hest = mean(hratio, 2);
        
        %% Obtain the payload coded symbols
        rxSymsPayload0 = rxSyms(:, nSymsPreamble+1:end); % get the payload
        
        
        %% Assume oracle knowledge of noise power
        noiseEst = noisePwr;
        
        %% MMSE Estimation of Tx Symbols
        rxSymsPayload = Hest'*((Hest*Hest'+noiseEst.*eye(nOutputs))\rxSymsPayload0);
        
        %% Normalize to unit average power        
        rxSymsPayload = rxSymsPayload./sqrt(mean(abs(rxSymsPayload).^2));
        
        if(plotFlag) % if plotFlag is asserted at top of file, and it's the first frame...
            scatterplot(rxSymsPayload) % show received payload symbols in IQ plane with scatterplot
        end

        %% Integer representation of payload symbols
        rxSymsInt = pskdemod(rxSymsPayload, M, 0, 'gray');
        
        %% Convert coded symbols from integer to binary representation
        rxCodedBits = de2bi(rxSymsInt, log2(M)).';
        
        %% Vectorize rxCodedBits to column vector
        rxCodedBitsVect = rxCodedBits(:);
        
        %% Organize coded bits into codewords
        rxCodedBitsCodewords = reshape(gf(rxCodedBitsVect), nwords, n);
        
        %% Perform BCH decoding
        rxMsg = bchdeco(rxCodedBitsCodewords, k, t);
        
        %% Compute the number of errors after decoding
        %txMsg = params.compiledMsg(ff).txMsg;
        txMsg = gf(params.trueBits(:, :, ff));
        numErrors(cc) = sum(sum(abs(rxMsg-txMsg.x)));
        
    end
    % take the output "A" or "B" which minimizes the number of bit errors
    % (this is assumed to be the SOI)
    errorCount(ff) = min(numErrors); 
    disp(['Number of errors ', num2str(min(numErrors))])
end

% compute the bit-error-rate
ber = mean(errorCount)./numel(rxMsg);

% compute the frame success rate
frameSuccessRate = length(find(errorCount == 0))./nFrames;
disp(['Bit Error Rate is ', num2str(ber)])
disp(['Frame Success Rate is ', num2str(frameSuccessRate)])


