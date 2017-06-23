% Main processing script for LFP data 
% Adapted from Ahmad's version starting 6/2017
% Output: Results structure with the following fields
% A field for each condition (currently 'Cue and 'Onset')
% A subfield for 

% ET subjects
subjectLists;
subjects = ET_subjects;
%subjects = {'DBS4038', 'DBS4040', 'DBS4046', 'DBS4047', 'DBS4049', 'DBS4051', 'DBS4053', 'DBS4054', 'DBS4055', 'DBS4056'};

pbSpect = 0;
fq=[2:2:200]'; %frequencies
stat.voxel_pval=0.05; stat.cluster_pval=0.05; stat.surrn=1;

if ispc
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
end

load([codeDir filesep 'Filters' filesep 'bandpassfilters.mat']);
load([codeDir filesep 'Filters' filesep 'highoass_2Hz_fs1200.mat']);
load([codeDir filesep 'Filters' filesep 'BroadbandGammaFilt.mat']);

% Broadband Gamma Filter Generation Code - saved but this is the function call
% BroadbandGammaFilt = designfilt('bandpassfir', 'StopbandFrequency1', 45, 'PassbandFrequency1', 50, 'PassbandFrequency2', 200, 'StopbandFrequency2', 205, 'StopbandAttenuation1', 45, 'PassbandRipple', .1, 'StopbandAttenuation2', 45, 'SampleRate', 1200);

pad=4000; % Needs to be > longest filter length, 2713 samples
Cond={'Cue','Onset'};
freq={'delta','theta','alpha','beta1','beta2', 'Gamma', 'Hgamma', 'BroadbandGamma'};
%freq={'beta1','beta2','BroadbandGamma'};
%freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
if ispc
    datadir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
else
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
end

ref=1; %1 is common reference avg, 0 is unreferenced
%h=1;
%Results=[];
%%

for s=8:length(subjects)
    tmp=dir([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep subjects{s} '*.mat']);
    for fi=1:length(tmp)
        data=load([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep tmp(fi).name],'Ecog','trials','nfs');
        disp(['Loaded data from ' tmp(fi).name]);
        %data=load([datadir filesep tmp(fi).name],'Ecog','trials','nfs');
        input=filtfilt(hpFilt,data.Ecog);
        if ref;  input= bsxfun(@minus,input,mean(input,2));  end
        ch=size(input,2);
        %reject=[find(isnan(data.trials.SpOnset))' find(isnan(data.trials.SpOffset))' data.trials.ResponseReject.all'];
        if (isfield(data.trials, 'SpEnd')); data.trials.SpOffset = data.trials.SpEnd; end
        reject = [find(isnan(data.trials.SpOnset))' find(isnan(data.trials.SpOffset))'];
        if length(data.trials.BaseRejectNoise)<10
            reject=unique([reject , data.trials.BaseRejectNoise']);
        else 
            reject=unique(reject);
        end
        trIndx=setdiff(1:60,reject);
        E0=data.trials.BaseFwd(setdiff(1:60,reject));
        E1=data.trials.BaseBack(setdiff(1:60,reject));
        E2=data.trials.SpOnset(setdiff(1:60,reject));
        E3=data.trials.SpOffset(setdiff(1:60,reject));
        
        [artifact]=auto_reject(input,E1,1200);
        artifact=unique(horzcat(artifact{:}));
        E0(artifact)=[];    E1(artifact)=[];   E2(artifact)=[];     E3(artifact)=[];
        trIndx(artifact)=[];
        nt=length(E1);
        if nt>5
            for c=1:length(Cond)
                switch Cond{c}
                    case 'Cue'
                        prestim=round(0.5*data.nfs);
                        poststim=round(mean(E2-E1)*data.nfs);
                        E2use=E1;
                    case 'Onset'
                        prestim=round(0.5+mean(E2-E1)*data.nfs);
                        poststim=round(1+mean(E3-E2)*data.nfs);
                        E2use=E2;
                end
                
                
                %bdur=round(min(E1-E0)*data.nfs);
                bdur=round(1*data.nfs);
                
                disp('Calculating wavelet spectra');
                [Results(h).(Cond{c}).zsc, tr, Results(h).Base.spect]=calc_ERSP(input, data.nfs, fq, E2use, prestim/data.nfs, poststim/data.nfs, E1, 1,stat);
                if pbSpect
                    trTime = -prestim:poststim;
                    plotSpect(trTime(:), fq, Results(h).(Cond{c}).zsc(:,:,1));
                end
                Results(h).(Cond{c}).meanPSD = squeeze(mean(abs(tr),3));
                Results(h).(Cond{c}).parameters={'prestim',prestim/data.nfs,'poststim',...
                    poststim/data.nfs,'baselinedur',bdur/data.nfs,'TrialN',nt,...
                    'trialsUsed',trIndx,'ChannelN',ch,'ComRef',ref};
                trial=arrayfun(@(x) input(x-prestim-pad:x+poststim+pad,:),round(E2use*data.nfs),'Uni',0);
                trial=cat(2,trial{:});
                base=arrayfun(@(x) input(x-bdur-pad:x+pad,:),round(E1*data.nfs),'Uni',0);
                base=cat(2,base{:});
                
                for f=1:length(freq)
                    disp(['Filtering at ' freq{f}]);
                    eval(['theseeve=' freq{f} 'Filt;']);
                    % bandpass filter into appropriate band and remove the padding
                    cmp_tr=hilbert(filtfilt(theseeve,trial));
                    cmp_tr=cmp_tr(pad+1:end-pad,:); % The trial portion to analyze
                    cmp_bs=hilbert(filtfilt(theseeve,base));
                    cmp_bs=cmp_bs(pad+1:end-pad,:); % The trial baseline
                    % z-score power to baseline
                    z_amp=bsxfun(@rdivide, bsxfun(@minus, abs(cmp_tr).^2,mean(abs(cmp_bs).^2)),std(abs(cmp_bs).^2));
                    Results(h).(Cond{c}).(freq{f}).z_Amp=z_amp;
                    Results(h).(Cond{c}).(freq{f}).tr=cmp_tr;
                    Results(h).(Cond{c}).(freq{f}).bs=cmp_bs;
                    
                    % normalize complex data for IPC calculation
                    cmp_tr=cmp_tr./abs(cmp_tr);
                    cmp_bs=cmp_bs./abs(cmp_bs);
                    
                    % intertrial phase consistency
                    Results(h).(Cond{c}).(freq{f}).IPC_tr=cell2mat(arrayfun(@(x) abs(mean(cmp_tr(:,x:ch:end),2)),1:ch,'Uni',0));
                    
                    % Rayleigh test
                    R = nt*Results(h).(Cond{c}).(freq{f}).IPC_tr;
                    Results(h).(Cond{c}).(freq{f}).z_IPC = (R.^2) / nt;
                    %  P-value for Rayleigh test
                    Results(h).(Cond{c}).(freq{f}).p_IPC = exp(sqrt(1+4*nt+4*(nt^2-R.^2))-(1+2*nt));
                    
                    % baseline IPC
                    Results(h).(Cond{c}).(freq{f}).IPC_bs=cell2mat(arrayfun(@(x) abs(mean(cmp_bs(:,x:3:end),2)),1:ch,'Uni',0));
                end
            end
            Results(h).Session=tmp(fi).name;
            
            clearvars R cmp_tr cmp_bs input data reject E0 E1 tr
            h=h+1;
        end
        mem = memory;
        if mem.MemUsedMATLAB > .8e11
            disp('Exiting bc of memory error');
            break;
        end
    end
    
    if mem.MemUsedMATLAB > .8e11
        break;
    end
end
disp('Saving population data file');
save('Band_modulation_referenced_ET_v2','Results','-v7.3');
