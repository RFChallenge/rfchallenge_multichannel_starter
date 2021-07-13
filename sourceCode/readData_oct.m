% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.


%% READDATA
% Purpose: reads in SigMF data (IQ data file and meta data file)
% Input: inputFilename of SigMF file
% Output: 
%     Y is an Nr - by - Nsamples matrix of complex baseband samples
%             where Nr is the number of receive antennas
%                   Nsamples is the number of samples per antenna
%     fdescStruct is a structure containing the contents of the meta-data
%         file

function Y = readData_oct(inputFilename, Nr, extStr)

%% IQ Data read (from binary file)
fid = fopen([inputFilename, '.', extStr],'rb');

if(fid == -1)
   error(['Could not open data file ', inputFilename, extStr, ' with fopen()']); 
end

try
    fullVect = fread(fid, inf, 'float32', 0, 'l');
catch
    error(['Could not read from filename ', inputFilename, extStr, ' with fread()']);
end
fclose(fid);
disp(['Finished reading IQ file ', inputFilename, extStr]);

vectComplex = fullVect(1:2:end) + (1j)*fullVect(2:2:end); % convert from separate real/imag vectors to a single complex vector

sampPerAnt = length(vectComplex)./Nr; % compute samples per antenna
if((sampPerAnt - fix(sampPerAnt))~=0)
   error('Number of samples in the IQ data file is not a multiple of the number of rx antennas Nr');
end

Y = reshape(vectComplex, sampPerAnt, Nr); % reshape to Nr - by - Nsamples output
Y = Y.';


