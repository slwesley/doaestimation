function [bp] = beampatt(array,d,pts)
%% Function Description
%
% Generate uniformly weighted beam pattern response over the field of view domain (see [1]) in dB scale;
%
%% Variables Description
%
% Input Variables:
% array: sensors positions
% d: minimum inter-element spacing in terms of lambda
% pts: number of points over which the beampattern will be calculated
%
% Output Variables:
% bp: Beam Pattern (dB)
%
%% References
%
% [1] H. L. Van Trees, Optimum Array Processing: Part IV of Detection, Estimation and Modulation Theory. 
% p. 43, New York: Wiley-Interscience, 2002.
% 
%% Author
% Wesley S. Leite (2024)
%
%%

array = array(:);
whole_fview = linspace(-1,1,pts); whole_fview = whole_fview(:);
bp = 20*log10(abs(sum(exp(1i*2*pi*d*array*whole_fview')/length(array))));
end

