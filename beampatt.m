function [bp] = beampatt(pos,pts)
%{
Generate beam pattern response over the u domain (see [1]) in dB scale;

pos: physical sensor positions
pts: number of points over which the beampattern will be calculated

[1] Harry L. Van Trees. (2002). Optimum Array Processing: Part IV of Detection, 
Estimation, and Modulation Theory. Optimum Array Processing Part IV of Detection, 
Estimation, and Modulation Theory. https://doi.org/10.1016/B978-0-08-010590-1.50004-4

%}

pos = pos(:);
u = linspace(-1,1,pts); u = u(:);
bp = 10*log10(abs(sum(exp(1i*pi*pos*u')/length(pos))));
end

