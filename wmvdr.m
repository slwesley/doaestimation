function [doa,Pmvdr] = wmvdr(R,array,D,grid,d)
%% Function Description
%
% Compute "D" DoA estimates, and the corresponding power spectrum using the MVDR (capon) beamscan beamformer
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
% Pmvdr: power spectrum (resulted from beamscan)
% doa: normalized DoAs  (sine of DoAs)
%
%% References
%
% [1] J. Capon, “High-resolution frequency-wavenumber spectrum analysis,” Proceedings of the IEEE, vol. 57, 
% no. 8, pp. 1408–1418, 1969, doi: 10.1109/PROC.1969.7278.
%
% [2] H. L. Van Trees, Optimum Array Processing: Part IV of Detection, Estimation and Modulation Theory. 
% New York: Wiley-Interscience, 2002.
% 
%% Author
% Wesley S. Leite (2024)
%
%%
array = array(:);
ngrid = length(grid);
Pmvdr = zeros(ngrid,1);
for i=1:ngrid
    a = exp(1i*2*pi*d*array*grid(i));   
    Pmvdr(i) = real(1/(a'*(R\a)));
end

% extract doa from spectrum
doa = spect2doa(Pmvdr,D,grid);

end

