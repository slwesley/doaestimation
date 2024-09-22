function [doa,Pmvdr] = wmvdr(R,array,D,grid,d)

array = array(:);
ngrid = length(grid);
Pmvdr = zeros(ngrid,1);
for i=1:ngrid
    a = exp(1i*2*pi*d*array*grid(i));   
    Pmvdr(i) = real(1/(a'*(R\a)));
end

% extract doa from spectrum
doa = spect2doa(Pmvdr,D,grid);

end

