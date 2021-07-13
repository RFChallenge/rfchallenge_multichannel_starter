% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

function validateInput(varIndex, minValvar, maxValvar, varStr)
  
if(varIndex - fix(varIndex) ~= 0 || varIndex <= 0)
  error('Input variable ', varStr, ' must be a positive integer');
end

if(varIndex < minValvar)
  error(['Input variable ', varStr, ' must be greater than ', num2str(minValvar)]);
end

if(varIndex > maxValvar)
  error(['Input variable ', varStr, ' must be less than ', num2str(maxValvar)]);
end


