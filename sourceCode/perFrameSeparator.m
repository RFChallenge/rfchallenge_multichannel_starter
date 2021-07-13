% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

%% PERFRAMESEPARATOR
% Reference function for separating signals in a particular frame

% Inputs:
% inputFilename: filename containing signal mixture to separate
% Nr: number of receive antennas

% Output:
% sigSep: nSources x numSamples matrix containing separated signals

function sigSep = perFrameSeparator(inputFilename, Nr)

%% Read IQ Data and MetaData
Y = readData_oct(inputFilename, Nr, 'iqdata');

nSources = 2;
nSensors = size(Y, 1);

% run ICA on this frame
sigHat = complexFastICA(Y, nSources);
           
% normalize separated components to unit average power
for sI=1:size(sigHat, 1)
  sigHat(sI, :) = sigHat(sI, :) ./  sqrt(mean(abs(sigHat(sI, :)).^2));
end
    
sigSep = sigHat;



