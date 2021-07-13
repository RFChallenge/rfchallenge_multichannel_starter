% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

%% EVALMAIN
% Purpose: top-level script for evaluating performance on RFChallenge Multi-sensor problem

clear all; clc; close all;


%% Participants: please specify directory in which input signal mixture files are stored
%% Path can be relative or absolute
inputDirectory = ['..', filesep, 'mixtureData'];

%% Participants: please specify directory in which separated output files are stored
%% Path can be relative or absolute
outputDirectory = ['..', filesep, 'sepOutput'];

%% Participants: please set frameLenVect to vector of frame lengths over which you wish to evaluate performance
%% Example: For frame lengths 4 and 32, use frameLenVect = [4, 32]
frameLenVect = [32];

%% Participants: please set setList to vector of setIndex values over which you wish to evaluate performance
%% Example: To evaluate performance over sets 3 and 5, use setList = [3, 5]
setList = [1];

%% Participants: please do not change code below this line

separationOpt = 'ICA';
nSources = 2;  
nR = 4;
NalphaIndices = 25;
nFrames = 100;
%%

%% Initialize randomizer (for deterministic behavior of ICA reference signal separator)
rand('seed', 123456789)

for ww=1:length(frameLenVect) % sweep over frame length
  frameLen = frameLenVect(ww); % get the current frame length
  
  % load in meta-data .mat files for the current frame length 
  load(['..\soiParamFiles\soiParams', num2str(frameLen), '.mat'], 'soiParamsPart')
  load(['..\soiParamFiles\stats', num2str(frameLen), '.mat'], 'medianSINR')

  for ss=1:NalphaIndices % sweep over alphaIndex
    
    for ii=1:1:length(setList); % sweep over setIndex
      
      currSet = setList(ii);
      
      %% REPLACE THIS FUNCTION WITH YOUR SIGNAL SEPARATOR
      %[~, ~, ~] = refSeparator('ICA', ss, frameLen, currSet, nFrames, nR, [], []);
      [~, ~, ~] = sigSeparator(inputDirectory, outputDirectory, 'ICA', ss, frameLen, currSet, nFrames, nR);
      
      % obtain the SOI parameters for this (frame length, alphaIndex, setIndex) tuple
      currParams = soiParamsPart(ss, currSet); 
      
      % evaluate separation performance in terms of "frame success rate" (mean fraction of frames with zero bit errors)
      [frameSuccessRateM(ww, ss, ii), berM(ww, ss, ii)] = evaluateSeparation(outputDirectory, ss, frameLen, currSet, nSources, currParams, nR);
    end
      
  end
  
  % plot results for the current frame length
  figure(ww);
  meanFrameSuccessRate = squeeze(mean(frameSuccessRateM(ww, :, :), 3));
  medianSINRAll = median(medianSINR, 2);
  plot(medianSINRAll, meanFrameSuccessRate, 'b')
  grid on
  xlabel('Median SINR (dB)')
  ylabel('Frame Success Rate')
  set(gca, 'FontSize', 24)
  title(['Frame Length: ', num2str(frameLen), ' words'])
  
  % determine the threshold SINR ensuring a mean frame success rate of at least 90% (i.e. <10% frame error rate)
  I = find(meanFrameSuccessRate > 0.9, 1, 'last');
  if(~isempty(I))
    sinrThresh(ww) = medianSINRAll(I);
  else
    sinrThresh(ww) = NaN;  
  end

end

save('results.mat') % save results to file

% plot final results for 90%-success threshold SINR as a function of frame length (in units of codewords)
figure(ww+1)
plot(frameLenVect, sinrThresh, '*-')
grid on
ylabel('SINR Threshold for <10% Frame Error')
xlabel('Number of Codewords Per Frame') 
set(gca, 'FontSize', 32)
title('Performance Evaluation vs. Codewords Per Frame')

% plot final results for 90%-success threshold SINR as a function of frame length (in units of symbols)
figure(ww+2)
plot( (soiParamsPart(1, 1).nPreambleBits+soiParamsPart(1, 1).n*frameLenVect)./log2(soiParamsPart(1, 1).M), sinrThresh, '*-')
grid on
ylabel('SINR Threshold for <10% Packet Error')
xlabel('Number of Symbols per Frame') 
set(gca, 'FontSize', 32)
title('Performance Evaluation vs. Symbols per Frame')