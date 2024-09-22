function [w,coArrayPositionsFilled,I,J,coArrayPositions] = weigfunct(sensorsPosition)
% WEIGFUNCT *Compute the weight function for a difference co-array of an array of 
% _any_ geometry*
% 
% This function returns the weights of a co-array (number of times a lag 
% value appears by taking the difference co-array of any array)
% 
% *Variables Description*
% 
% * *sensorsPosition*: physical array sensors postions
% * *w*: co-array elements weights
% * *coArrayPositions*: co-array elements
% * *I*: index indicating the sorting and removing procedure in order to obtain 
% the sorted (ascending) co-array elements from the general redundant co-array 
% positions
% 
% *References*
% 
% [1] P. Pal and P. P. Vaidyanathan, “Nested arrays: A novel approach to 
% array processing with enhanced degrees of freedom,�? _IEEE Trans. Signal Process._, 
% vol. 58, no. 8, pp. 4167–4181, 2010. 
% 
% Author: Wesley Leite (February, 20th. 2019)

N = length(sensorsPosition);
C = sensorsPosition(:)*ones(1,N)-ones(N,1)*sensorsPosition(:).';
% redundantCoArrayPositions = round(log(kron(exp(-sensorsPosition(:)),...
    % exp(sensorsPosition(:)))));
redundantCoArrayPositions = C(:);
    [coArrayPositions,I] = unique(redundantCoArrayPositions);
% Obtain weight function
coArrayPositionsFilled = coArrayPositions(1):coArrayPositions(end);
coArrayPositionsFilled = coArrayPositionsFilled(:);
w = histc(redundantCoArrayPositions,coArrayPositionsFilled);
n1 = (length(coArrayPositions)+1)/2;
Ii = cell(2*n1-1,1);

for i=1:n1
    Ii{i} = (C==coArrayPositions(i));
end
for i=(n1+1):(2*n1-1)
    Ii{i} = Ii{2*n1-i}.';
end

J = zeros(N^2,2*n1-1);
for i=1:(2*n1-1)
    J(:,i) = Ii{i}(:);
end

end