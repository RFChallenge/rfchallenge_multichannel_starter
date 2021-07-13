% Research was sponsored by the United States Air Force Research Laboratory and the United States Air Force Artificial Intelligence Accelerator
% and was accomplished under Cooperative Agreement Number FA8750-19-2-1000. The views and conclusions contained in this document are those of the 
% authors and should not be interpreted as representing the official policies, either expressed or implied, of the United States Air Force or the 
% U.S. Government. The U.S. Government is authorized to reproduce and distribute reprints for Government purposes notwithstanding any copyright 
% notation herein.

function sigHat = complexFastICA(xin, n)
  
eps = 0.1; % epsilon in G
m = size(xin, 2); %number of sensors
% Whiten the data
[Ex, Dx] = eig(cov(xin'));
R = sqrt(inv(Dx)) * Ex';
x = R * xin;
p = size(xin, 1);  
W = zeros(p, n); %initialize beamforming matrix
nIterMax = 40;
for k = 1:n % find n independent component signals sequentially
  w = rand(p,1) + i*rand(p,1); % randomly initialize beamforming weight vector for k-th component
  iterCount = 0;
  wprev = zeros(p,1);

  % iterative update for finding k-th independent component
  while (iterCount < nIterMax) && (sum(abs(abs(wprev) - abs(w))) > 0.001)
    wprev = w;
    g = 1./(eps + abs(w'*x).^2); % compute derivative
    dg = -1./(eps + abs(w'*x).^2).^2; % compute second derivative      
    w = mean(x .* (ones(p,1)*conj(w'*x)) .* (ones(p,1)*g), 2) - ...
    mean(g + abs(w'*x).^2 .* dg) * w; % update weight vector   
    w = w / norm(w); % normalization
    % decorrelation of k-th component with respect to components 1:k-1
    w = w - W*W'*w;
    w = w / norm(w);
    iterCount = iterCount + 1;    
  end     
  W(:,k) = w;     
end;         
% apply beamforming weight matrix to obtain the independent components
sigHat = W'*x; 

      
      
