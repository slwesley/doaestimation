function [z] = chkcovmat(X,nSources)
% CHKCOVMAT Determine whether a matrix is hermitian positive semidefinite (PSD) using its eigenvalue decomposition.
% Additionaly, it compares the number os sources and the dimensions of the
% covariance matrix.
% Author: Wesley S. Leite (2022)

smt = ishermitian(X);
d = eig(X);
tol = length(d)*eps(max(d));
y = (all(d>-tol)) && smt;

if (~y)
    error('The sources covariance matrix is not hermitian PSD!') 
end

w = (length(X) == nSources);  
if(~w)
    error('The covariance matrix dimensions do not match the number of sources.')
end

z = y && w;



end

