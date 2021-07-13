% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

%% WRITEDATA
% Purpose: writes SigMF data (IQ data file and meta data file)
% Input: 
%       outputFilename of SigMF file
%       sig is a Nr - by - Nsamples matrix of complex baseband samples
%       inputStruct is a structure containing the meta-data to write to the
%           meta-data file

function writeData_oct(outputFileName, sig, inputStruct)

if(isempty(sig))
   error('No data to write'); 
end

if(inputStruct.Nr ~= size(sig, 1))
   error(['User-specified number of receive antennas is ', num2str(inputStruct.Nr), '. Expecting data matrix to have ', num2str(inputStruct.Nr),  ' rows']); 
end

temp = sig.'; % Transpose sig matrix to be Nsamples - by - Nr matrix
%% IQ Samples: First write IQ samples to binary file
sigMixWrite = [real(temp(:).'); imag(temp(:).')];
sigMixIQInterleaved = sigMixWrite(:);

fid = fopen([outputFileName, '.iqdata'],'wb');
fwrite(fid, sigMixIQInterleaved, 'float32', 0, 'l');
fclose(fid);


