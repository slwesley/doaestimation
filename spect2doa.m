function doa = spect2doa(spect,D,grid)
%% Function Description
%
% Extract "D" DoA estimates from (pseudo)-spectrum
%
%% Variables Description
%
% Input Variables:
% spect: (pseudo)-spectrum
% D: number of impinging sources
% grid: discretized search grid
%
% Output Variables:
% doa: normalized DoAs (sine of DoAs)
%
%% References
%
% [1] The author.
%
%% Author
% Wesley S. Leite (2024)
%
%%
[~,peaksIndex] = findpeaks(abs(spect),'NPeaks',D,'SortStr','descend');
peaksIndex = sort(peaksIndex,'ascend');
theta_hat = grid(peaksIndex)'; theta_hat = theta_hat(:);

% handling missing values for dimensions compatibility during RMSE
% computation
mis = D-length(theta_hat);
if(mis>0)
    ngrid = length(grid);
    rand_doa_index = randperm(ngrid);
    rand_doa = grid(rand_doa_index(1:mis)); rand_doa = rand_doa(:);
    theta_hat = [theta_hat; rand_doa];
else
    while(mis<0)
        theta_hat(end) = [];
        mis = mis+1;
    end
end
doa = sort(theta_hat,'ascend');

end

