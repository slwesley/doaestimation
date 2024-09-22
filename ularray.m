function arrayPositions = ularray(N)
% ULAARRAY Obtain the physical sensors positions for a N sensors ULA.
% 
% *Variables Description*
% 
% * *N*: total number of physical sensors
% * *arrayPositions*: physical sensors positions on the grid 
% 
% 
% Author: Wesley Leite (February, 26th. 2019)
% N1 and N2 are the number of physical sensors in each nested level (inner
% and outer level, respectively)

% physical sensors positions ranging from 0 to N-1
arrayPositions = (0:(N-1))';
arrayPositions = arrayPositions(:);
end
