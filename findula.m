function M = findula(w)
% FINDULA Returns the extreme central ULA position for any co-array.
% 
% Remark: the total uniform DoF is given by 2*M+1.
% 
% *Variables Description:*
% 
% * *w*: weights obtained by means of weigfunct() function.
% * *M*: extreme central ULA co-array position
% 
% *References*
% 
% [1] P. Pal and P. P. Vaidyanathan, “Nested arrays: A novel approach to 
% array processing with enhanced degrees of freedom,�? _IEEE Trans. Signal Process._, 
% vol. 58, no. 8, pp. 4167–4181, 2010. 
% 
% Author: Wesley Leite (February, 18th. 2019)
% Obtain extreme central co-array ULA position
% In case of Nested Arrays, there is no holes. So, the variable M is equal
% to the extreme position of the co-array. However, in case of co-prime
% arrays, that is not true and then we have to find the entral co-array
% ULA.

M = (length(w)-1)/2;
for i=(M+2):(2*M+1)
    if w(i)==0
        M = i-(M+2);
        break;
    end
end
end