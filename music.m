function [spect] = music(R,pos,gs,D,d)
%{
% performs spectral MUSIC for DOA estimation

Inputs
- R: sample covariance matrix
- sensors_pos: sensors position
- nGrid: grid length over -pi/2 to pi/2
- D: number of sources
- d: normalized minimum inter-element spacing in terms of wavelength 
%}

spect = zeros(length(gs),1);
gs = gs(:); gs = gs.';
pos = pos(:);
ngrid = length(gs);
N = length(R);
[U,V] = eig(R);
[~,vv] = sort(abs(diag(V)),'ascend');
U = U(:,vv);
Un = U(:,1:(N-D)); % noise subspace
A = exp(1i*2*pi*d*pos*gs);

for i=1:ngrid    
    spect(i) = real(1/norm(Un'*A(:,i),2)^2);
end

end

