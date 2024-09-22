clc; clear; close all

% basic algorithm to implement some simple DoA estimation scripts

SNR = -15:5;
snaps = 200;

% Spectrum algorithms (1D search)
nameOfAlg_spect = {'MUSIC','Bartlett','Capon'};

% Search-free algorithms
nameOfAlg_searchFree = {'rMUSIC'};
% nameOfAlg_searchFree = [];

% All algorithms
nameOfAlg = [nameOfAlg_spect, nameOfAlg_searchFree]; % name of all algorithms
nAlg = length(nameOfAlg); % number of all algorithms (spectrum and search-free as well)

% Beampattern Parameters
ptsbeamp = 512; % number of points for the beampattern evaluation


% Array geometry
nSensors = 10; % number of sensors
nameOfArray = {'ULA'};
arrayStruct = arraygen(nSensors,1,nameOfArray,eye(nSensors),ptsbeamp);

% search grid
nGrid = 512;  % number of points in the grid search 
gridLimits = [-.9 .9]; % limits for the field of view
searchGrid = linspace(gridLimits(1),gridLimits(2),nGrid); searchGrid = searchGrid(:); % grid

% DoAs
% nSources = 3;
% prelimTheta = linspace(-.7,.7,nSources); % preliminary directions (sine of DoAs)
prelimTheta = [-.2,0,.3]
nSources = length(prelimTheta);
prelimTheta = prelimTheta(:);
[preliminaryTheta,ascendThetaInd] = sort(prelimTheta,'ascend');
[~,thetaIndices] = mink(abs(searchGrid*ones(1,nSources)-ones(nGrid,1)*preliminaryTheta'),1); % closest DOAs indices on the grid for the intended directions defined in aux_theta
effectiveTheta = searchGrid(thetaIndices);
effectiveTheta = effectiveTheta(:); % effective directions - directions on 
% the grid closest to preliminary directions. Notice that we perform on the grid DoA estimation

% Sources covariance matrix
varSources = 1; % sources power
normSensorSpacing = .5; % minimum intersensor spacing interms of carrier wavelength
covSources = eye(nSources);
chkcovmat(covSources,nSources) % check covariance matrix
covSources = covSources(ascendThetaInd,ascendThetaInd);


% Projection matrix to transform the data in order to follow covSources correlation structure
projToCorrelate = corrdata(covSources,'singvaldec',nSources);

% Plot covariance matrix (magnitude an phase for each element)
%{
subplot(2,1,1); sgtitle('Sources Covariance Matrix')
imagesc(abs(covSources)); colorbar; colormap pink; title('magnitude')
subplot(2,1,2); imagesc(angle(covSources)/pi); colorbar('Ticks',[-1 -3/4 -1/2 -1/3 0 1/3 1/2 3/4 1],...
    'TickLabels',{'-\pi','-3\pi/4','-\pi/2','-\pi/3','0','\pi/3','\pi/2','3\pi/4','\pi'}); colormap hot; title('phase')
%}



%% Plots
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

%%  A) Single trial plots

% Received signal covariance matrix
[~,~,~,~,~,R] = rawdata(arrayStruct.position,snaps,effectiveTheta,varSources,projToCorrelate,...
                    SNR(end-1),normSensorSpacing);

% A.1) Power spectra
if ~isempty(nameOfAlg_spect)
    figure;
    vline(effectiveTheta.'); % draw DoAs as dashed black lines
    xticks(round(effectiveTheta,2))  % Set customized ticks
    title(nameOfArray,'FontSize',14)
    ax = gca; ax.FontSize = 15;  % Change this to your desired font size
    ylabel('Normalized Power Spectrum','FontSize',16); xlabel('$\theta$','Interpreter','latex','FontSize',20);
    hold on;
    axis([-.6 .6 0 1.05])
    for i=1:length(nameOfAlg_spect)
        switch nameOfAlg_spect{i}
            case 'MUSIC'
                [~,spect] = wmusic(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                plot(searchGrid,spect/max(abs(spect)),'-','Color',colors_custom.values(i,:),'LineWidth',1.5)
            case 'Bartlett'
                [~,spect] = wbart(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                plot(searchGrid,spect/max(abs(spect)),'-','Color',colors_custom.values(i,:),'LineWidth',1.5);
            case 'Capon'
                [~,spect] = wmvdr(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                plot(searchGrid,spect/max(abs(spect)),'Color',colors_custom.values(i,:),'LineWidth',1.5);
            otherwise
                error([nameOfAlg_spect{i},' is not a valid name for algorithm!'])
        end
    end
    legend(nameOfAlg_spect,'FontSize',14)
end


%% B) Root Mean-Squared Error (RMSE) plots, using multiple trials
nTrials = 1e4; % number of trials
squared_errors = zeros(nAlg,length(SNR),nTrials); % storage variable for squared errors
RMSE = zeros(nAlg,length(SNR)); % RMSE storage

for k=1:length(SNR)
    currentSnr = SNR(k);
    noiseVar = varSources*10^(-currentSnr/10);
    parfor j=1:nTrials
        [~,~,~,~,~,R] = rawdata(arrayStruct.position,snaps,effectiveTheta,varSources,projToCorrelate,...
            SNR(k),normSensorSpacing);
        for i=1:nAlg
            switch nameOfAlg{i}
                case 'MUSIC'
                    [doa_est,~] = wmusic(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'Bartlett'
                    [doa_est,~] = wbart(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'Capon'
                    [doa_est,~] = wmvdr(R,arrayStruct.position,nSources,searchGrid,normSensorSpacing);
                case 'rMUSIC'
                    [doa_est] = wroot_music(R,arrayStruct.position,nSources,normSensorSpacing);
                otherwise
                    error([nameOfAlg{i},' is not a valid name for algorithm!']);
            end
        squared_errors(i,k,j) = (1/nSources)*norm(doa_est-effectiveTheta,2)^2;
        end        
    end
    k
end

% compute RMSE for all algorithms
for k=1:nAlg
    RMSE(k,:) = squeeze(sqrt(mean(squared_errors(k,:,:),3)));
end
%%

hmc = figure; hold on
ax = gca; ax.FontSize = 15;  % Change this to your desired font size
for i=1:nAlg
    h = plot(SNR,RMSE(i,:),markers{i},'Color',colors_custom.values(i,:),'LineWidth',2,'MarkerSize',mksizec);    
    set(h,'MarkerFaceColor',get(h,'color'))
end
% axis labels, legens and title
xlabel('SNR (dB)','FontSize',14); ylabel('RMSE','FontSize',14);
legend(nameOfAlg,'FontSize',14); title(nameOfArray,'FontSize',14)
set(gca,'YScale','log'); hmc.PaperPositionMode = 'auto';