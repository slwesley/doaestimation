function [doa,Pmusic] = wmusic(R,array,D,grid,d)
%% Function Description
%
% Compute "D" DoA estimates, and the corresponding power spectrum using the MUSIC algorithm
%
%% Variables Description
%
% Input Variables:
% R: received signal covariance matrix
% array: sensors positions
% D: number of impinging sources
% grid: discretized search grid
% d: minimum inter-element spacing
% 
% Output Variables:
% Pmusic: normalized music pseudo-spectrum
% doa: normalized DoAs
%
%% References
%
% [1] [1] R. Schmidt, “Multiple emitter location and signal parameter estimation,” IEEE Transactions on 
% Antennas and Propagation, vol. 34, no. 3, pp. 276–280, Mar. 1986, doi: 10.1109/TAP.1986.1143830.
%
% [2] H. L. Van Trees, Optimum Array Processing: Part IV of Detection, Estimation and Modulation Theory. 
% New York: Wiley-Interscience, 2002.
% 
%% Author
% Wesley S. Leite (2024)
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
