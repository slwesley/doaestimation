function [z] = chkcovmat(R,nSources)
%% Function Description
%
% Determine whether a matrix is hermitian positive semidefinite and PSD using its eigenvalue decomposition.
% Additionaly, it compares the number os sources and the dimensions of the
% covariance matrix.
%
%% Variables Description
%
% Input Variables:
% R: sources covariance matrix
% nSources: number of sources
%
% Output Variables:
% z: state variable (True if conditions are met. False otherwise.)
%
%% References
%
% [1] The author.
%
%% Author
% Wesley S. Leite (2024)
%
%%

smt = ishermitian(R);
d = eig(R);
tol = length(d)*eps(max(d));
y = (all(d>-tol)) && smt;

if (~y)
    error('The sources covariance matrix is not hermitian PSD!') 
end

w = (length(R) == nSources);  
if(~w)
    error('The covariance matrix dimensions do not match the number of sources.')
end

z = y && w;



end

