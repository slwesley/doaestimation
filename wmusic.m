function [doa,Pmusic] = wmusic(R,array,D,grid,d)
%% Function Description
%
% Compute "D" DoA estimates using the MUSIC algorithm
%
%% Variables Description
%
% R: received signal covariance matrix
% array: sensors positions
% D: number of impinging sources
% grid: discretized search grid
% d: minimum inter-element spacing
% Pmusic: normalized music pseudo-spectrum
% doa: normalized DoAs
%
%% References
%
% [1] 
%
% Author: Wesley Leite
%
%%
ngrid = length(grid);
array = array(:);
N = length(array);
[delta,lambda] = eig(R); % perform eigendecomposition on R
[~,ind] = sort(diag(lambda),'descend'); % Sort eigenvalues in descending order
delta = delta(:,ind); % rearrange eigenvectors according to the eigenvalues order
deltan = delta(:,(D+1):N); % take the noise subspace basis

% compute pseudo-spectrum
Pmusic = zeros(ngrid,1);
for j=1:ngrid
    a = exp(1i*2*pi*d*array*grid(j));
    Pmusic(j) = 1/(a'*(deltan*deltan')*a);
end
Pmusic = abs(Pmusic);

% extract doa from spectrum
doa = spect2doa(Pmusic,D,grid);

end
