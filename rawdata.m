function [X,S,A,Rs,Rsn,R_est,Rn] = rawdata(arrayPositions,snaps,theta,var_source,P,SNR,d)
%% Function Description 
%
% This function generate the 2-level nested array "raw" data, according 
% to a prespecified total number of sensors, total number of snapshots, sources 
% DoA and SNR.
% 
%% Variables Description
% 
% arrayPositions: physical sensor positions in units of minimum inter-element
% spacing d
% T: total number of snapshots
% theta: normalized sources directions (sine of DOAs) 
% var_source: source variance
% SNR: signal-to-noise ratio, in dB
% d: minimum inter-element spacing in wavelength units
% C: coupling matrix (identity matrix for no coupling)
% Rsrc: true source sovariance matrix
% n_coher: number of coherent sources
% X: received signal snapshots
% S: source signals snapshots
% A: array manifold matrix
% R_est: est received signal covariance matrix
%% References
%
% [1] P. Pal and P. P. Vaidyanathan, “Nested arrays: A novel approach to 
% array processing with enhanced degrees of freedom,��? _IEEE Trans. Signal Process._, 
% vol. 58, no. 8, pp. 4167–4181, 2010. 
% 
% Author: Wesley Leite (February, 18th. 2019)
%
%%
m = length(arrayPositions);
A = exp(1i*2*pi*d*arrayPositions(:)*theta(:)'); % array manifold
D = length(theta); % number of sources
var_noise = var_source*10^(-SNR/10); % noise variance 
S = P*(sqrt(var_source/2)*randn(D,snaps)+1i*sqrt(var_source/2)*randn(D,snaps)); % sources signals
N = sqrt(var_noise/2)*randn(m,snaps)+1i*sqrt(var_noise/2)*randn(m,snaps);
% X = zeros(m,snaps); % received signal
% L = length(nSensorsSubarrays);

% changes the SNR for each subarray 
% beta = 10.^(SNRSubarrays/20);
% iinf = 1;
% for l=1:L
%     isup = iinf+nSensorsSubarrays(l)-1;
%     S(iinf:isup,:) = beta(l)*S(iinf:isup,:);
% end

Rs = (1/snaps)*(S*S'); % sources cov. matrix
Rn = (1/snaps)*(N*N'); % noise cov. matrix
Rsn = (1/snaps)*(S*N'); % sources-noise cross cov. matrix

X=A*S+N;
R_est = (1/snaps)*(X*X');

end
