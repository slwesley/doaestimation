function doa = wls_esprit(R,array,D,d)
%% Function Description
%
% Compute "D" DoA estimates using the Least Squares(LS)-ESPRIT algorithm
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
% doa: normalized DoAs (sine of DoAs)
%
%% References
%
% [1] H. L. Van Trees, Optimum Array Processing: Part IV of Detection, Estimation and Modulation Theory. 
% p. 1171-1175. New York: Wiley-Interscience, 2002.
% 
%% Author
% Wesley S. Leite (2024)
%
%%

if ~isCentroSymmetricArray(array)
    error('The array geometry for LS-ESPRIT must be centro-symmetric!')
end


array = array(:);
N = length(array);
Ns = N-1; % ESPRIT parameter - size of overlapping subarrays
[delta,lambda] = eig(R); % perform eigendecomposition on R
[~,ind] = sort(diag(lambda),'descend'); % Sort eigenvalues in descending order
delta = delta(:,ind); % rearrange eigenvectors according to the eigenvalues order
deltas = delta(:,1:D); % take the signal subspace basis

Us1 = deltas(1:Ns,:);
Us2 = deltas(N-Ns+1:end,:);
Psi = ((Us1'*Us1)\Us1')*Us2; % the form (Us1'*Us1)^-1 is the identity matrix
tot_roots = eig(Psi);
doa = (angle(tot_roots)/(N-Ns))/(2*pi*d);

% roots to DoAs conversion
doa = doa(:);
doa = sort(doa,'ascend');

end
