N = (3:17)';

NR = [0
0
1
2
4
5
7
9
12
16
20
23
26
30
35];

Na = [3
6
9
13
17
23
29
36
43
50
58
68
79
90
101];

N2Na = ((N.^2)./Na);
%{
[
3.0
2.67
2.78
2.77
2.88
2.78
2.79
2.78
2.81
2.88
2.91
2.88
2.85
2.84
2.86];
%}
RedunQuant = N.*(N-1)./(2*Na);

positions = {[0 1 3]';
[0 1 4 6]';
[0 1 4 7 9]'; 
[0 1 4 5 11 13]'; 
[0 1 4 10 12 15 17]'; 
[0 1 4 10 16 18 21 23]';
[0 1 4 10 16 22 24 27 29]';
[0 1 3 6 13 20 27 31 35 36]';
[0 1 3 6 13 20 27 34 38 42 43]';
[0 1 3 6 13 20 27 34 41 45 49 50]';
[0 1 2 3 27 32 36 40 44 48 52 55 58]';
[0 1 2 8 15 16 26 36 46 56 59 63 65 68]';
[0 1 2 5 10 15 26 37 48 59 65 71 77 78 79]';
[0 1 2 5 10 15 26 37 48 59 70 76 82 88 89 90]';
[0 1 2 5 10 15 26 37 48 59 70 81 87 93 99 100 101]'};


data_MRA = struct('N',N,'N_REDUN',NR,'Na',Na,'N2overNa',N2Na,'RedundancyMeas',RedunQuant);  
data_MRA.positions = positions;



%%
% table. Columns as [N Nr Na]
numArrays = 7;
table = zeros(numArrays,3);
for i=1:numArrays
    [~,table(i,2),table(i,3)] = arrayStat(positions{i});
    table(i,1)= length(positions{i});
    positions{i}'
end
table
