%% Direction of Arrival (DOA) Estimation
%% General description
% Performs array processing for DOA estimation using multiple algorithms, data 
% models, pre-processing schemes, and multiple (sub)array geometries. The simulation 
% scenarios can be set up to include electromagnetic (EM) coupling  effects (B-banded 
% mode model).
% 
% Advisor: Prof. Rodrigo C. De Lamare
% 
% Author: Wesley S. Leite (2022) @ Pontifical Catholic University of Rio de 
% Janeiro - PUC-Rio (CETUC)
% 
% Version: 2.0.3 (see associated release notes)
% List of acronyms

%% Geometries names
% * *ULA*: Uniform Linear Array
% * *CPA*: Coprime Arrays
% * *NAQN*: N-Level Nested Array
% * *SNAQN*: N-th Order Super Nested Array
% * *MRA*: Minimum Redanduncy Array
% * *GNA*: Generalized Nested Array
% * *CAD*: Generalized Coprime Array with Displaced Subarrays
% * *MHA*: Minimum Hole Arrays
% * *SPC*: Spectrum

%% Simulation setup
% *General definitions*

clearvars; close all; clc

% rng('default') % for repeatability
mCarloRuns = 10000; % number of Monte Carlo runs
% SNR = -20:3:20; % signal-to-noise ratio (dB)
% SNR = -40:3:40; % signal-to-noise ratio (dB)
SNR = -5:2:20;
snaps = 500;

% *Define arrays geometries and algorithms to be evaluated*

% Algorithms
% nameOfAlg = {'GCA-MUSIC','GCA-rMUSIC','G-MUSIC'};
% nameOfAlg = {'GCA-rMUSIC','GCA-MUSIC','G-MUSIC','SS-MUSIC','MUSIC'};
% nameOfPabs = {'GCA-rMUSIC','GCA-MUSIC','SS-MUSIC'};
% nameOfAlg = {'GCA-MUSIC','GCA-rMUSIC','G-MUSIC'}; 
% nameOfAlg = {'GCA-MUSIC','GCA-rMUSIC','G-MUSIC','SPEC-RARE'};
% nameOfAlg = {'GCA-rMUSIC','GCA-MUSIC','SS-MUSIC','SPEC-RARE','G-MUSIC'};
% nameOfAlg = {'GCA-rMUSIC','GCA-MUSIC','SS-MUSIC','SPEC-RARE','G-MUSIC','CRLB-FC-UP','CRLB-PC-UP-PROP'};
% nameOfAlg = {'GCA-rMUSIC','GCA-MUSIC'};
% nameOfAlg = {'CRLB-PC-UP-PROP'};
% nameOfAlg = {'GCA-rMUSIC','GCA-MUSIC','SS-MUSIC','SPEC-RARE','G-MUSIC','CRLB-FC-UP','CRLB-PC','CRLB-PC-NP','CRLB-PROP'};
% nameOfAlg = {'CA-MUSIC-VCA-a=0','CA-MUSIC-VCA-a=1','CA-MUSIC-VCA-a=2','CA-MUSIC-VCA-a=3','CA-MUSIC-VCA-a=4','CA-MUSIC-VCA-a=5','CA-MUSIC-VCA-a=9'};

% VSW-(G)CA-MUSIC names generator
vws_a = 0:6;
radical = 'VWS-CA-rMUSIC';
nameOfAlg = cell(1, length(vws_a));
for i = 1:length(vws_a)
    nameOfAlg{i} = [radical,'-a=', num2str(vws_a(i))];
end

% nameOfAlg = {'VSW-CA-MUSIC-a=0','VSW-CA-MUSIC-a=1',...
%     'VSW-CA-MUSIC-a=2','VSW-CA-MUSIC-a=3',...
%     'VSW-CA-MUSIC-a=4','VSW-CA-MUSIC-a=5',...
%     'VSW-CA-MUSIC-a=6','VSW-CA-MUSIC-a=7',...
%     };
% kindOfAlg = [0 1 1 1 1]; % 1 for spectrum-based / 0 for root-based
% kindOfAlg = [1 0 1 1]; % 1 for spectrum-based / 0 for root-based
kindOfAlg = ones(1,length(nameOfAlg));
numberOfAlg = length(nameOfAlg);
% numberOfPabs = length(nameOfPabs);

% Geometries
nameOfArrays = {'I-SNAQ2','I-MHA','I-MRA','I-NAQ2'};
% nameOfArrays = {'II-MHA','II-SNAQ2','II-MRA','II-NAQ2'};
% nameOfArrays = {'II-SNAQ2'};
% nameOfArrays = {'II-CPA'};
numberOfArrays = length(nameOfArrays);

% *Subarrays related definitions*

nSubarrays = 1; % number of subarrays
nSensorSubarrays = 7*ones(nSubarrays,1); % number of sensors for each subarray 
nSensors = sum(nSensorSubarrays); % total number of physical sensors for the linear array
% Relative SNR between subarrays, in dB. The first subarray has an SNR equal to the SNR point defined by the variable SNR.
SNRSubarrays = zeros(1,nSubarrays); % = zeros(1,nSubarrays) for the subarrays without differences in SNR 
% Define the subarrays regarding coherence (interfers with the data acquisition model)
spacingBetweenSubarrays = 1; % spacing between subarrays in units of spacing(d)/lambda

% *Coupling model definitions*

B = 0; % Coupling model parameter - B=0 for no EM coupling
ptsbeamp = 512; % number of points for the beampattern evaluation
varSources = 1; % sources power
normSensorSpacing = .5; % minimum normalized inter-sensor spacing (d)

% Search grid settings

nGrid = 512;  % number of points for the grid search algorithms
gridLimits = [-.9 .9];
searchGrid = linspace(gridLimits(1),gridLimits(2),nGrid); searchGrid = searchGrid(:);
% *Sources profile*

% * *Sources DOA*
% [preliminaryTheta,ascendThetaInd] = sort([-.4 -.25 -.1 0 .1 .25 .4].','ascend'); % define preliminary normalized directions (sine of DOAs)
% [preliminaryTheta,ascendThetaInd] = sort([-.8 -.6 -.4 0 .4 .6 .8].','ascend'); % define preliminary normalized directions (sine of DOAs)
% [preliminaryTheta,ascendThetaInd] = sort([-.8 -.6 -.4 -.3 .3 .4 .6 .8].','ascend'); % define preliminary normalized directions (sine of DOAs)
% [preliminaryTheta,ascendThetaInd] = sort([-.6 -.5 -.4 -.3 -.2 .2 .3 .4 .5 .6].','ascend'); % define preliminary normalized directions (sine of DOAs)
% [preliminaryTheta,ascendThetaInd] = sort([-.5 -.4 -.3 -.2 0 .2 .3 .4 .5].','ascend');
% sourceSpacing = .2;
nSources = 8;
% prelimTheta = sourceSpacing*(-ceil((nSources-1)/2):floor((nSources-1)/2));
prelimTheta = linspace(-.8,.8,nSources);
prelimTheta = prelimTheta(:);
[preliminaryTheta,ascendThetaInd] = sort(prelimTheta,'ascend');
[~,thetaIndices] = mink(abs(searchGrid*ones(1,nSources)-ones(nGrid,1)*preliminaryTheta'),1); % closest DOAs indices on the grid for the intended directions defined in aux_theta
effectiveTheta = searchGrid(thetaIndices);
effectiveTheta = effectiveTheta(:);

% * *Sources covariance matrix*

% a) Generation step according to one of the following models:

% Model 1 - Baseband complex fading coefficients model
% rho = [0.9*exp(1i*pi/180*135) 0.8*exp(1i*pi/180*70) 0.85*exp(1i*pi/180*98) 0.7*exp(1i*pi/180*231)]';  
% covSources = blkdiag(eye(2),rho(1:2)*rho(1:2)',rho(3:4)*rho(3:4)');
% rho = [0.9*exp(1i*pi/180*135) 0.9*exp(1i*pi/180*70) 0.85*exp(1i*pi/180*98) 0.7*exp(1i*pi/180*231)].';   
% covSources = blkdiag(eye(2),rho(1:2)*rho(1:2)',rho(3:4)*rho(3:4)');


% Model 2 - Uncorrelated sources model
covSources = eye(nSources);

% b) Validation step
chkcovmat(covSources,nSources) 

condNumberSourcesCovMat = cond(covSources);
covSources = covSources(ascendThetaInd,ascendThetaInd);

% c) Information gathering step (correlated, uncorrelated and groups of
% correlated sources)
[sources_info.uncorr,sources_info.corr,sources_info.coher_groups] = chksources(covSources);

% Generate a projection matrix to project uncorrelated data onto a predefined space with cov. matrix given by covSources
projToCorrelate = corrdata(covSources,'singvaldec',nSources);

% Plot covariance matrix (magnitude an phase for each element)
%{
subplot(2,1,1); sgtitle('Sources Covariance Matrix')
imagesc(abs(Rsrc)); colorbar; colormap pink; title('magnitude')
subplot(2,1,2); imagesc(angle(Rsrc)/pi); colorbar('Ticks',[-1 -3/4 -1/2 -1/3 0 1/3 1/2 3/4 1],...
    'TickLabels',{'-\pi','-3\pi/4','-\pi/2','-\pi/3','0','\pi/3','\pi/2','3\pi/4','\pi'}); colormap hot; title('phase')
%}

%% Compute array structure
array_struct = arraygen(nSensorSubarrays,spacingBetweenSubarrays,nameOfArrays,B,ptsbeamp);

%% Compute performance curves
%
tStartRmse = tic;
rmseFULL = perfcurves(array_struct,nameOfAlg,kindOfAlg,...
    snaps,SNR,varSources,projToCorrelate,covSources,normSensorSpacing,effectiveTheta,...
    thetaIndices,searchGrid,mCarloRuns,nSensorSubarrays,SNRSubarrays)
tElapsedRmse = toc(tStartRmse)/60;
%}

%
% folder to save the results
folderName = datetime;
folderName.Format = 'yyyy-MM-dd_HH.mm.ss';
resultsFolder = ['output','/',char(folderName)];
mkdir(resultsFolder)

save([resultsFolder,'/','allVariables'], '-regexp', '^(?!h.*$).')
%}
%% Plot and save results

run mainplotsave