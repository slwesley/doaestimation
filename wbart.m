function [doa,Pbart] = wbart(R,array,D,grid,d)
%% Function Description
%
% Compute "D" DoA estimates, and the corresponding power spectrum using the Bartlett beamscan beamformer
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
% Pbart: power spectrum (resulted from beamscan)
% doa: normalized DoAs (sine of DoAs)
%
%% References
%
% [1] H. L. Van Trees, Optimum Array Processing: Part IV of Detection, Estimation and Modulation Theory. 
% New York: Wiley-Interscience, 2002.
% 
%% Author
% Wesley S. Leite (2024)
%

array = array(:);
ngrid = length(grid);
Pbart = zeros(ngrid,1);
for i=1:ngrid
    a = exp(1i*2*pi*d*array*grid(i));   
    Pbart(i) = real(a'*R*a);
end

% extract doa from spectrum
doa = spect2doa(Pbart,D,grid);

end

