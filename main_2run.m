clc; clear; close all % some cleaning
%%
% Description 
% Performs parametric DoA estimation using second-order statistics,
% assuming narrowband, far-field sources impinging on a linear sensor array
%
%% Author
% Wesley S. Leite (Aug, 2024)
%
%% Initial settings

SNR = -15:5; % sets the SNR range
snaps = 30:40:350; % sets multiple snapshot quantities (data samples)

% Spectrum-based algorithms to be simulated (1D search)
% Choose between 'MUSIC','Bartlett', and 'MVDR'
nameOfAlg_spect = {'MUSIC','Bartlett','MVDR'};
% nameOfAlg_spect = []; % uncomment to exclude this class of algorithms
nAlgSpect = length(nameOfAlg_spect);

% Search-free algorithms to be simulated
% Choose between 'rMUSIC', 'rMVDR', and ,'LS-ESPRIT'
nameOfAlg_searchFree = {'rMUSIC','rMVDR','LS-ESPRIT'};
% nameOfAlg_searchFree = []; % uncomment to exclude this class of algorithms

% Merge all algorithms
nameOfAlg = [nameOfAlg_spect, nameOfAlg_searchFree]; % name of all algorithms
nAlg = length(nameOfAlg); % number of all algorithms (spectrum and search-free as well)

% Beampattern parameters
ptsbeamp = 512; % number of points for the beampattern evaluation

%% Define array geometry
% choose between 'ULA', 'MRA', 'MHA', 'NAQ2', 'SNAQ2' etc. Inspect
% arraygen() for additional array geometries, such as
% rMUSIC, rMVDR: ULA / LS-ESPRIT: centro-symmetric arrays (ULA works,
% because it is centro-symmetric
nSensors = 10; % number of sensors
nameOfArray = {'ULA'}; % Array geometry name. Choose only one geometry at a time
normSensorSpacing = .5; % minimum intersensor spacing interms of carrier wavelength
arrayStruct = arraygen(nSensors,1,nameOfArray,eye(nSensors),ptsbeamp,normSensorSpacing);

%% Search grid
nGrid = 512;  % number of points in the discretized field of view (search grid) 
gridLimits = [-.9 .9]; % limits for the field of view
searchGrid = linspace(gridLimits(1),gridLimits(2),nGrid); 
searchGrid = searchGrid(:); % ensure the grid is a column

%% Define trues to be estimated
prelimTheta = [-.2 0 .3];
nSources = length(prelimTheta);
prelimTheta = prelimTheta(:);
[preliminaryTheta,ascendThetaInd] = sort(prelimTheta,'ascend');
[~,thetaIndices] = mink(abs(searchGrid*ones(1,nSources)-ones(nGrid,1)*preliminaryTheta'),1); % closest DOAs indices on the grid for the intended directions defined in aux_theta
effectiveTheta = searchGrid(thetaIndices);
effectiveTheta = effectiveTheta(:); % Effective directions: directions on 
% the grid closest to preliminary directions. Notice that we perform on 
% the grid DoA estimation

%% Source covariance matrix
varSources = 1; % sources power
covSources = eye(nSources); % A model of uncorrelated sources was chosen, which is a 
% standard assumption for many algorithms. However, models with correlated or fully 
% coherent sources can also be adopted. The data generation model in function rawmatrix() 
% will simulate the correlation structure as required
chkcovmat(covSources,nSources) % check for the validity of the covariance matrix
covSources = covSources(ascendThetaInd,ascendThetaInd);

%% Projection matrix to transform the data to follow the 'covSources' correlation structure
projToCorrelate = corrdata(covSources,'singvaldec',nSources);

%% Optional
% Plot source covariance matrix using 2D imagesc (magnitude and phase for each of its elements). 
%
% subplot(2,1,1); sgtitle('Sources Covariance Matrix')
% imagesc(abs(covSources)); colorbar; colormap pink; title('magnitude')
% subplot(2,1,2); imagesc(angle(covSources)/pi); colorbar('Ticks',[-1 -3/4 -1/2 -1/3 0 1/3 1/2 3/4 1],...
%     'TickLabels',{'-\pi','-3\pi/4','-\pi/2','-\pi/3','0','\pi/3','\pi/2','3\pi/4','\pi'}); colormap hot; title('phase')
%
%% Plot settings
% define customized colors palette 
colors_custom.names = {'darker_green','blue_skye','darker_orange','darker_magenta','gray_mod','magenta'}; % customized color names
colors_custom.values = [0 .7 0;
                        0.2 0.6 0.8;
                        0.95 0.6 0;
                        0.6 0 0.6;
                        0.4, 0.6, 0.4;
                        .8 0 .8];
% define customized markers
markers = {'d--','^-','s-.','o-','h-.','s-.','d:','s--','d-.','s-','v-.','>-.','v-','p-.'};
mksizec = 7; % marker size
% In case you plot more than six curves, just add more RGB triplets with the 
% corresponding desired color names in 'colors_custom.names'

%% Multiple trial settings
%
% Define single values of SNR and snapshots to be used in the spectra calculations
% and RMSE responses as well
chosenSNR = SNR(end-1); % choose any value from 'SNR' vector. In this case, 
% second-to-last element is the default option
chosenSnaps = snaps(6); % choose any number of snapshots from 'snaps' vector.
nTrials = 1e4; % number of Monte Carlo trials in order to have well behaved curves. 
% Increase if necesssary (case of challenging simulation scenarios) 

%%  A) Compute spectrum responses
% Spectral responses over a discretized field of view (grid) under specified SNR and snapshot conditions

% Received signal covariance matrix
[~,~,~,~,~,R] = rawdata(arrayStruct.position,chosenSnaps,effectiveTheta,varSources,projToCorrelate,...
                    chosenSNR,normSensorSpacing);

spect = zeros(nGrid,nAlgSpect);
% Plot only the algorithms that generate a pseudo-spectrum, excluding
% search-free DoA estimation algorithms, i.e., the algorithms in 'nameOfAlg_spect'
if ~isempty(nameOfAlg_spect)    
    for i=1:nAlgSpect
        switch nameOfAlg_spect{i}
            case 'MUSIC'
                [~,spect(:,i)] = wmusic(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing); % MUSIC algorithm
            case 'Bartlett'
                [~,spect(:,i)] = wbart(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing); % Bartlett beamformer for DoA estimation
           case 'MVDR'
                [~,spect(:,i)] = wmvdr(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing); % Capon or MVDR beamformer for DoA estimation
            otherwise
                error([nameOfAlg_spect{i},' is not a valid name for algorithm!'])
        end
    end
end
% Observe that you can add more algorithms in this section, just giving
% them a name and putting the corresponding function in the same folder as
% this main script

%% B) Multiple trials for RMSE calculation
%
% B.1) RMSE curves against SNR range computation

squared_errors_snr = zeros(nAlg,length(SNR),nTrials); % storage variable for squared errors
RMSE_snr = zeros(nAlg,length(SNR)); % RMSE storage
for k=1:length(SNR)
    currentSnr = SNR(k);
    parfor j=1:nTrials
        [~,~,~,~,~,R] = rawdata(arrayStruct.position,chosenSnaps,effectiveTheta,varSources,projToCorrelate,...
            SNR(k),normSensorSpacing);
        for i=1:nAlg
            switch nameOfAlg{i}
                case 'MUSIC'
                    [doa_est,~] = wmusic(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'Bartlett'
                    [doa_est,~] = wbart(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'MVDR'
                    [doa_est,~] = wmvdr(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'rMUSIC'
                    [doa_est] = wroot_music(R,arrayStruct.position,nSources,normSensorSpacing);
                case 'rMVDR'
                    [doa_est] = wroot_mvdr(R,arrayStruct.position,nSources,normSensorSpacing);
                case 'LS-ESPRIT'
                    [doa_est] = wls_esprit(R,arrayStruct.position,nSources,normSensorSpacing);
                otherwise
                    error([nameOfAlg{i},' is not a valid name for algorithm!']);
            end
        squared_errors_snr(i,k,j) = (1/nSources)*norm(doa_est-effectiveTheta,2)^2;
        end        
    end
    k
end
% compute RMSE against SNR for all algorithms
for k=1:nAlg
    RMSE_snr(k,:) = squeeze(sqrt(mean(squared_errors_snr(k,:,:),3)));
end

%% B.2) RMSE curves against snapshots range

squared_errors_snaps = zeros(nAlg,length(snaps),nTrials); % storage variable for squared errors
RMSE_snaps = zeros(nAlg,length(snaps)); % RMSE storage
for k=1:length(snaps)
    currentSnaps = snaps(k);    
    parfor j=1:nTrials
        [~,~,~,~,~,R] = rawdata(arrayStruct.position,currentSnaps,effectiveTheta,varSources,projToCorrelate,...
            chosenSNR,normSensorSpacing);
        for i=1:nAlg
            switch nameOfAlg{i}
                case 'MUSIC'
                    [doa_est,~] = wmusic(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'Bartlett'
                    [doa_est,~] = wbart(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'MVDR'
                    [doa_est,~] = wmvdr(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'rMUSIC'
                    [doa_est] = wroot_music(R,arrayStruct.position,nSources,normSensorSpacing);
                case 'rMVDR'
                    [doa_est] = wroot_mvdr(R,arrayStruct.position,nSources,normSensorSpacing);
                case 'LS-ESPRIT'
                    [doa_est] = wls_esprit(R,arrayStruct.position,nSources,normSensorSpacing);
                otherwise
                    error([nameOfAlg{i},' is not a valid name for algorithm!']);
            end
        squared_errors_snaps(i,k,j) = (1/nSources)*norm(doa_est-effectiveTheta,2)^2;
        end        
    end
    k
end
% Compute RMSE against snapshots for all algorithms
for k=1:nAlg
    RMSE_snaps(k,:) = squeeze(sqrt(mean(squared_errors_snaps(k,:,:),3)));
end
%% C) Plotting 
% In section C), we handle the plotting.

%% C.1) Array geometry beam pattern 

figure; % open new figure object
title(nameOfArray,'FontSize',14) % set title
ax = gca; ax.FontSize = 15;  % change default axis font size
ylabel('Beam Pattern (dB)','FontSize',16); % change y-axis label
xlabel('$\theta$','Interpreter','latex','FontSize',20); % change x-axis label
hold on; % freeze plots in the loop after adding them
xlim([-.98 .98]); % lower and upper limits for x-axis (limits for the field of view)
domain_bp = linspace(-1,1,ptsbeamp);
beamPattern = beampatt(arrayStruct.position,normSensorSpacing,ptsbeamp);
plot(domain_bp,beamPattern,'k-','LineWidth',1.5);


%% C.2) Spectra 

if ~isempty(nameOfAlg_spect)
    figure; % open new figure object
    vline(effectiveTheta.'); % draw DoAs as vertical black dashed lines
    xticks(round(effectiveTheta,2))  % set customized ticks for x-axis
    title(nameOfArray,'FontSize',14) % set title
    ax = gca; ax.FontSize = 15;  % change default axis font size
    ylabel('Normalized Power Spectrum','FontSize',16); % change y-axis label
    xlabel('$\theta$','Interpreter','latex','FontSize',20); % change x-axis label
    hold on; % freeze plots in the loop after adding them
    axis([-.6 .6 0 1.05]); % lower and upper limits for x- and y-axis
    for i=1:nAlgSpect
        plot(searchGrid,spect(:,i)/max(abs(spect(:,i))),'-','Color',colors_custom.values(i,:),'LineWidth',1.5);
    end
    legend(nameOfAlg_spect,'FontSize',14) % update legend with the name of all spectrum-based algorithms
end

%% C.3) RMSE curves

% C.3.1) RMSE curves against SNR
hh = figure;
subplot(1,2,1); hold on; grid
ax1 = gca; ax1.FontSize = 15;  % Change this to your desired font size
axis([SNR(1) SNR(end) min(RMSE_snr(:)) max(RMSE_snr(:))]); % lower and upper limits for x- and y-axis
for i=1:nAlg
    h1 = plot(SNR,RMSE_snr(i,:),markers{i},'Color',colors_custom.values(i,:),'LineWidth',2,'MarkerSize',mksizec);    
    set(h1,'MarkerFaceColor',get(h1,'color'))
end
% axis labels, legends and title
xlabel('SNR (dB)','FontSize',14); ylabel('RMSE','FontSize',14);
legend(nameOfAlg,'FontSize',14);
set(gca,'YScale','log');

% C.3.2) RMSE curves against snapshots
subplot(1,2,2); hold on; grid
ax2 = gca; ax2.FontSize = 15;  % Change this to your desired font size
axis([snaps(1) snaps(end) min(RMSE_snaps(:)) max(RMSE_snaps(:))]); % lower and upper limits for x- and y-axis
for i=1:nAlg
    h2 = plot(snaps,RMSE_snaps(i,:),markers{i},'Color',colors_custom.values(i,:),'LineWidth',2,'MarkerSize',mksizec);    
    set(h2,'MarkerFaceColor',get(h2,'color'))
end
% axis labels, legends and title
xlabel('snapshots','FontSize',14); ylabel('RMSE','FontSize',14);
legend(nameOfAlg,'FontSize',14);
set(gca,'YScale','log');
sgtitle('ULA', 'FontSize', 14, 'FontWeight', 'bold'); % title for both subplots
hh.PaperPositionMode = 'auto';
