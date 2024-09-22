function [P] = corrdata(R,met,nSources)
% CORRDATA Generate a projection matrix for the standard multivariante normal 
% data such that a new data from  
% 
% P: projection matrix
% R: covariance matrix
% met: method to be used (cholesky or singvaldec) 

% check for covariance matrix semipositive definiteness and hermitian
% property
chkcovmat(R,nSources)
    
switch met
    case 'cholesky'
        P = chol(R,'lower');
    case 'singvaldec'
        [U,S,~] = svd(R);
        sqS = sqrt(round(S*1e6)/1e6);
        P = U*sqS*U';    
    otherwise
        error('Choose cholesky or singvaldec (SVD) as a valid method!')   
end

