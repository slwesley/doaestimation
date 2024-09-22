function [arrayPositions,N1,N2] = twonestarray(N)
% TWONESTARRAY Obtain the physical sensors positions for a 2-level nested array, according 
% to reference [1].
% 
% *Variables Description*
% 
% * *N*: total number of physical sensors
% * *arrayPositions*: physical sensors positions on the grid (needed by the 
% SS MUSIC algorithm)
% 
% *References*
% 
% [1] P. Pal and P. P. Vaidyanathan, “Nested arrays: A novel approach to 
% array processing with enhanced degrees of freedom,” _IEEE Trans. Signal Process._, 
% vol. 58, no. 8, pp. 4167–4181, 2010. 
% 
% Author: Wesley Leite (February, 18th. 2019)
% N1 and N2 are the number of physical sensors in each nested level (inner
% and outer level, respectively)
if(mod(N,2)==0)
    N1 = N/2;
    N2 = N1;
else
    N1 = (N+1)/2;
    N2 = (N-1)/2;
end
% physical sensors positions ranging from 0 to N2*(N1+1)-1
arrayPositions = [1:N1 (N1+1)*(1:N2)]'-1;
arrayPositions = arrayPositions(:);
end