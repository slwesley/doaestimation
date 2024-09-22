N = (3:17)';

positions = {[0 1 3]';
[0 1 4 6]';
[0 1 4 9 11]'; 
[0 1 4 10 12 17]'; 
[0 1 4 10 18 23 25]'; 
[0 1 4 9 15 22 32 34]';
[0 1 5 12 25 27 35 41 44]';
[0 1 6 10 23 26 34 41 53 55]';
[0 1 4 13 28 33 47 54 64 70 72]';
[0 2 6 24 29 40 43 55 68 75 76 85]';
[0 2 5 25 37 43 59 70 85 89 98 99 106]';
[0 4 6 20 35 52 59 77 78 86 89 99 122 127]';
[0 4 20 30 57 59 62 76 100 111 123 136 144 145 151]';
[0 1 4 11 26 32 56 68 76 115 117 134 150 163 168 177]';
[0 5 7 17 52 56 67 80 81 100 122 138 159 165 168 191 199]'};


data_MHA.N = N;  
data_MHA.positions = positions;

% table. Columns as [N Nh Na]
numArrays = 7;
table = zeros(numArrays,3);
for i=1:numArrays
    [table(i,2),~,table(i,3)] = arrayStat(positions{i});
    table(i,1)= length(positions{i});
    positions{i}'
end
table