function doa = wroot_capon(R,array,D,d)
%% Function Description
%
% Compute "D" DoA estimates using the root-Capon algorithm
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
% p. 1147-1148, New York: Wiley-Interscience, 2002.
% 
%% Author
% Wesley S. Leite (2024)
%
%%
if ~isSpacedByOne(array)
    error('The array geometry for root-Capon must be a ULA!')
end

array = array(:);
N = length(array);
coeffs_poly = zeros(2*N-1,1); % polynomial coefficients

invR = inv(R);
for j=1:2*N-1
    coeffs_poly(j) = sum(diag(invR,N-j));
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
