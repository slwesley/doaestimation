function C = mutcoup(arrayPositions,B)
%% Function Description
% This function generates the mutual coupling matrix according to the model
% described in [1] (Eq. (10)).
%% Variables Description
%
% arrayPositions: physical array positions (multiples of element spacing)
% B: B-banded mode
% C: mutual coupling matrix

%% References
%
% [1] Liu, C.-L., & Vaidyanathan, P. P. (2016). Super Nested Arrays: Linear 
% Sparse Arrays With Reduced Mutual Coupling—Part I: Fundamentals. IEEE 
% Transactions on Signal Processing, 64(15), 3997–4012. 
% https://doi.org/10.1109/TSP.2016.2558159
%
% Author: Wesley Leite (March, 19th. 2019)

%% 
n = length(arrayPositions);
if(B>0)
    % Compute the difference physical position numbers
    diffPos = abs(round(log(exp(arrayPositions(:))*...
        conj(exp(-arrayPositions(:)')))));
    % Set first coupling coefficient
    c1 = .3*exp(1i*pi/3);
    % Obtain coupling coefficients vector
    coupCoeffs = (c1.*(exp(-1i*((1:B)-1)*pi/8)./(1:B))).';
    if(max(diffPos,[],'all')>B)
        coupCoeffs(B+1:max(diffPos)) = 0;
    end
    auxDiag = diag(ones(n,1));
    C = coupCoeffs(diffPos+auxDiag);
    % Set main diagonal elements to 1
    idx = 1:n+1:numel(C);
    C(idx) = 1;
else
    C = eye(n);
end

