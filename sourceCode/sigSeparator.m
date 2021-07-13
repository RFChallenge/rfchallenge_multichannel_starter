% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

%% SIGSEPARATOR: Reference implementation of multi-channel signal separator

% Inputs
% inputDirectory: string file path to directory where mixture data is stored
% separationOpt: string indicating separation option to use
% alphaIndex: alphaIndex for the example being tested (see document rfChallenge_multisensor_intro)
% frameLen: frameLen for the example being tested (see document rfChallenge_multisensor_intro)
% setIndex: setIndex for the example being tested (see document rfChallenge_multisensor_intro)
% nFrames: number of frames to be evaluated
% nR: number of receive antennas

function [Y0, sigIn, W0] = sigSeparator(inputDirectory, outputDirectory, separationOpt, alphaIndex, frameLen, setIndex, nFrames, nR)

nOutputs = 1;
nSources = 2;
suffixStr = {'A', 'B'};

for ff = 1:nFrames % loop through the nFrames of this data instance
    
    % define file containing the mixture signal to separate
    inputFilename = [inputDirectory, filesep, 'input_frameLen_', num2str(frameLen), '_setIndex_', num2str(setIndex), '_alphaIndex_', num2str(alphaIndex), '_frame', num2str(ff)];

    % call perFrameSeparator function to perform signal separation on the current frame
    Y0 = perFrameSeparator(inputFilename, nR);
    
    % write separated signals to "outputA" and "outputB" files
    for oo=1:size(Y0, 1)
      currSuffix = suffixStr{oo};
      inputStruct.sample_rate = 25e6;
      inputStruct.description = 'separatedSignals';
      inputStruct.Nr = 1;
      outputFilename = [outputDirectory, filesep, 'output', currSuffix, '_frameLen_', num2str(frameLen), '_setIndex_', num2str(setIndex), '_alphaIndex_', num2str(alphaIndex), '_frame', num2str(ff)];
      writeData_oct(outputFilename, Y0(oo, :), inputStruct)
    end
    
end
