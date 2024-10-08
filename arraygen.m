function [arset] = arraygen(nSensorSubarrays,spacingBetweenSubarrays,names,B,ptsbeamp,normSensorSpacing)
%{

ARRAYGEN

General Description:

Generate array structures as well as their fundamental quantities for the
purpose of simulation:
- Weight function
- Virtual co-array positions
- Total number of Degrees of Freedom (DoF)
- Total number of Uniform Degrees of Freedom (uDoF)
- Coupling matrix
- Coupling leakage coefficient

Additionally, display the weight function and coupling matrix colormap
for all the considered geometries

PS:
    1 - the arrays are generated by considering the first sensor as being in
the "0" position. All the positions are natural numbers multiple of the
normalized inter-element spacing "d".
    2- the MRA geometry have sensor positions pre-determined from classical
    literature. That is the reason why they are not algebraically computed.
    Only can be found through computer search. The multiple MRA geometries
    used here were extracted from Table 3.8 of [1].

Variables Description:

Input
- N: total number of physical sensors
- name: predefined geometry name according to the following acronym list
    ULA: Uniform Linear Array
    CPA: Coprime Arrays
    NAQ2: 2nd Order Nested Array
    SNAQ2: 2nd Order Super Nested Array
    NAQ3: Three-level Nested Array
    SNAQ3: 3tr-Order Super Nested Array
    MRA: Minimum Redunduncy Array
    GNA: Generalized Nested Array
    CAD: Generalized Coprime Array with Displaced Subarrays)
    MHA: Minimum Hole Array
- names: cell array with geometries names
- results_folder: output results folder
- ptsbeamp: number of points to plot the beam pattern

Output
- arset.position: physical sensors position
- arset.struct.weight: weight function coefficients
- arset.struct.virPos: co-array index in virtual domain (virtual positions)
- arset.permVec: permutation vector so that the differences between the positions
are unique
- arset.dof: total number of degrees of freedom
- arset.udof: uniform degrees of freedom (closely related to the restricted part
of the array)
- arset.coupMat: coupling matrix using the B-banded mode model
- arset.leakCoef: leakage coefficient associated with the coupling matrix

Author: Wesley S. Leite.  Last revised on Oct 28th, 2019.
Advisor: Rodrigo C. De Lamare
CETUC / PUC-Rio

%}

% Default parameter setting
arset = struct;
nArrays = length(names);
N = sum(nSensorSubarrays); % total number of physical sensors

if(nargin<=3)
    B = eye(nSensorSubarrays);
    ptsbeamp = 512;
else if (nargin==4)
    ptsbeamp = 512;
end

for i=1:nArrays
    switch names{i}
        case {'I-NAQ2','NAQ2'}
            arset(i).position = twonestarray(N);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,normSensorSpacing,ptsbeamp);
        case 'II-NAQ2'
            arset(i).position = twonestarray(nSensorSubarrays(1));            
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position); 
                sub = twonestarray(nSensorSubarrays(jj));
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,normSensorSpacing,ptsbeamp);
        case {'I-ULA','ULA'}
            arset(i).position = ularray(N);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-ULA'
            arset(i).position = ularray(nSensorSubarrays(1));
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position); 
                sub = ularray(nSensorSubarrays(jj));
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case {'I-CPA','CPA'}
            arset(i).position = coprimearray(N);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-CPA'
            arset(i).position = coprimearray(nSensorSubarrays(1));             
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position);
                sub = coprimearray(nSensorSubarrays(jj));
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case {'I-SNAQ2','SNAQ2'}
            arset(i).position = supernestarray(N,2);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-SNAQ2'
            arset(i).position = supernestarray(nSensorSubarrays(1),2);            
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position);
                sub = supernestarray(nSensorSubarrays(jj),2);
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);        
        case {'I-MRA','MRA'}
            if(N<3||N>17)
                error('The MRA database has arrays from 3 to 17 sensors!')
            end
            load('data/data_MRA.mat','data_MRA');            
            arset(i).position = (data_MRA.positions{data_MRA.N==N});
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-MRA'
            for ii=1:length(nSensorSubarrays)
                if(nSensorSubarrays(ii)<3 || nSensorSubarrays(ii)>17)
                    error('The MRA database has arrays from 3 to 17 sensors!')
                end
            end
            load('data/data_MRA.mat','data_MRA');
            arset(i).position = (data_MRA.positions{data_MRA.N==nSensorSubarrays(1)});            
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position); 
                sub = (data_MRA.positions{data_MRA.N==nSensorSubarrays(jj)});
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case {'I-GNA','GNA'}
            arset(i).position = genestarray(N);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-GNA'
            arset(i).position = genestarray(nSensorSubarrays(1));
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position); 
                sub = genestarray(nSensorSubarrays(jj));
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);        
        case 'I-CAD'
            arset(i).position = cadarray(N);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-CAD'
            arset(i).position = cadarray(nSensorSubarrays(1));            
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position); 
                sub = cadarray(nSensorSubarrays(jj));
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp); 
        case {'I-SNAQ3','SNAQ3'}
            arset(i).position = supernestarray(N,3);
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-SNAQ3'
            arset(i).position = supernestarray(nSensorSubarrays(1),3);
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position); 
                sub = supernestarray(nSensorSubarrays(jj),3);
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp); 
        case {'I-MHA','MHA'}
            if(N<3||N>17)
                error('The MHA database has arrays from 3 to 17 sensors!')
            end
            load('data/data_MHA.mat','data_MHA');
            arset(i).position = (data_MHA.positions{data_MHA.N==N});
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        case 'II-MHA'
            for ii=1:length(nSensorSubarrays)
                if(nSensorSubarrays(ii)<3 || nSensorSubarrays(ii)>17)
                    error('The MHA database has arrays from 3 to 17 sensors!')
                end
            end
            load('data/data_MHA.mat','data_MHA');
            arset(i).position = (data_MHA.positions{data_MHA.N==nSensorSubarrays(1)});
            for jj=2:length(nSensorSubarrays)
                aperture = max(arset(i).position)-min(arset(i).position);
                sub = (data_MHA.positions{data_MHA.N==nSensorSubarrays(jj)});
                arset(i).position = [arset(i).position; sub+spacingBetweenSubarrays+aperture];
            end
            arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
            arset(i).name = names{i};
            [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                weigfunct(arset(i).position);
            M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
            arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
            arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                ,'fro')/norm(arset(i).coupMat,'fro');
            arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
        
        otherwise
            if strcmp(extractBefore(names{i},'-'),'FRAC')
                r = 2; % array order
                % genN = (log(N)/log(r)); % number of generator sensors
                %if(genN~=N)
                %    error(['There is no such ' num2str(r) '-th order fractal array with ' num2str(N)...
                %        ' sensors \n The closest array has ' num2str(genN) ' sensors'])
                %end
                genN = 5;
                arset(i).position = fract(r,names{i},genN);
                arset(i).mispos = setdiff(0:max(arset(i).position),arset(i).position); % mising sensors location
                arset(i).name = names{i};
                [arset(i).weight,arset(i).virPos,arset(i).permVec,arset(i).j,arset(i).coarray] = ...
                    weigfunct(arset(i).position);
                M = findula(arset(i).weight); arset(i).dof = nnz(arset(i).weight);
                arset(i).coupMat = mutcoup(arset(i).position,B); arset(i).udof = 2*M+1;
                arset(i).leakCoef = norm(arset(i).coupMat-diag(diag(arset(i).coupMat))...
                    ,'fro')/norm(arset(i).coupMat,'fro');
                arset(i).uniBeamPat = beampatt(arset(i).position,normSensorSpacing,ptsbeamp);
            else
                error('Unknown geometry')
            end        
    end
end

end