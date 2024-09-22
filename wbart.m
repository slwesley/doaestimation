function [doa,Pbart] = wbart(R,array,D,grid,d)

array = array(:);
ngrid = length(grid);
Pbart = zeros(ngrid,1);
for i=1:ngrid
    a = exp(1i*2*pi*d*array*grid(i));   
    Pbart(i) = real(a'*R*a);
end

% extract doa from spectrum
doa = spect2doa(Pbart,D,grid);

end

