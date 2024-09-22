function doa = wroot_music(R,array,D,d)
%% Function Description
%
% Compute "D" DoA estimates using root-MUSIC algorithm
%
%% Variables Description
%
% R: received signal covariance matrix
% array: sensors positions
% D: number of impinging sources
% d: minimum inter-element spacing
% doa: normalized DoAs (sine of DoA estimates)
%
%% References
%
% [1] 
%
% Author: Wesley Leite
%
%%
array = array(:);
N = length(array);
[delta,lambda] = eig(R); % perform eigendecomposition on R
[~,ind] = sort(diag(lambda),'descend'); % Sort eigenvalues in descending order
delta = delta(:,ind); % rearrange eigenvectors according to the eigenvalues order
deltan = delta(:,(D+1):N); % take the noise subspace basis
proj_noise = deltan*deltan'; % projection matrix onto noise subspace
coeffs_poly = zeros(2*N-1,1); % polynomial coefficients

for j=1:2*N-1
    coeffs_poly(j) = sum(diag(proj_noise,N-j));
end

coeffs_poly = coeffs_poly./coeffs_poly(1); % normalization 
tot_roots = roots(coeffs_poly); 

% take the D roots closest and inside the unit circle (root pruning process)
[~,idx] = sort(abs(tot_roots(abs(tot_roots)<1)),'descend');
tot_roots_aux = tot_roots(abs(tot_roots)<1);
n_est_doas = min(D,length(idx)); % number of preliminary estimated DoAs
roots_final = tot_roots_aux(idx(1:n_est_doas));

% roots to DoAs conversion
doa = angle(roots_final)/(2*pi*d);
doa = doa(:);
doa = sort(doa,'ascend');

end
