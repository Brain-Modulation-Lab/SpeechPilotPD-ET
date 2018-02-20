setDirectories; %platform specific locations 
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
subjectLists; %load lists of subjects
subjects = ET_subjects;
%subjects = PD_subjects(6:end);
group = 'ET';

stat.voxel_pval=0.05; stat.cluster_pval=0.05; stat.surrn=1;

load([codeDir filesep 'Filters' filesep 'bandpassfilters.mat']);
load([codeDir filesep 'Filters' filesep 'highoass_2Hz_fs1200.mat']);
load([codeDir filesep 'Filters' filesep 'BroadbandGammaFilt.mat']);

pad=4000; % Needs to be > longest filter length, 2713 samples
Cond={'Cue','Onset'};
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
if ispc
    datadir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
else
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
end

ref=1; %1 is common reference avg, 0 is unreferenced
h=1;
Results=[];


for s=1:length(subjects)
    tmp=dir([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep subjects{s} '*.mat']);
    for fi=1:length(tmp)
        data=load([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep tmp(fi).name],'Ecog','trials','nfs', 'badch','labels', 'EcogLabels','Side', 'SubjectID', 'Session');
        if isfield(data, 'EcogLabels') data.labels = data.EcogLabels; end
        disp(['Loaded data from ' tmp(fi).name]);
        %need to read in a match to the anatomically localized
        electrodeLocs = readElectrodeLocXLS(electrodeFile, group); 
        ematch = find(strcmp(data.SubjectID, {electrodeLocs.subject}) & strcmpi(data.Side, {electrodeLocs.side}));
        for ii = 1:length(ematch) % There can be multiple strips per recording
            locLabels(cell2mat({electrodeLocs(ematch(ii)).channels})) = electrodeLocs(ematch(ii)).labels;
        end
%         find(strcmpi('Precentral Gyrus', locLabels))
%         ei = find(strcmpi('Precentral Gyrus', locLabels))
%         ch = length(ei);
        
        chUsed = setdiff(1:size(data.Ecog,2), data.badch); %select the good channels
        ch = length(chUsed);
        input=filtfilt(hpFilt,data.Ecog);
      
        reject=[find(isnan(data.trials.SpOnset))' find(isnan(data.trials.SpOffset))'];
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
        
        [artifact]=auto_reject2(input,E1,1200);
        artifact=unique(horzcat(artifact{:}));
        E0(artifact)=[];    E1(artifact)=[];   E2(artifact)=[];     E3(artifact)=[];
        trIndx(artifact)=[];
        nt=length(E1);
        tlen=round((0.5+max(E3-E1))*data.nfs);
        
        %% Calculate and plot the single trial response detection
        ncol = ceil(ch/14);
        [ah, fh] = subplot_pete(ceil(ch/ncol), ncol,'','', tmp(fi).name);
        fh.Position = [20 20 1400 1200]; % We want to make these big, then save them
        rxn=E2-E1;    [~,ia]=sort(rxn,'ascend');
        clearvars ZBB ActOnset ActiveWind
        for c=1:ch
            [ActOnset(:,c),ZBB(:,:,c)]=single_trial_detection(input(:,chUsed(c)),data.nfs,E1,E1,[E1(2:end); NaN], tlen,HgammaFilt);
            ic=~isnan(ActOnset(:,c)); activeT = find(ic);
            CueR=ActOnset(ic,c)/200; % /200 is conversion to seconds (200 Hz sample rate)
            for jj = 1:length(CueR)
                ActiveWind(:,jj,c) = ZBB(CueR(jj):(CueR(jj)+10), activeT(jj),c);
                MaxZ(jj,c) = nanmax(ActiveWind(:,jj,c));
            end
            SPR=(E2(ic)-ActOnset(ic,c))/200;
            axes(ah(c));
            image(0:1/200:size(ZBB,1)/200,1:size(ZBB,2),ZBB(:,ia,c)','CDataMapping','scaled')
            hold on
            if sum(isnan(ActOnset(:,c)))~=length(ActOnset)
                scatter(ActOnset(ia,c)/200,1:length(E1),35,'*','r')
            end
            if ~isempty(CueR)
                [rhoC,pvalC]=corr(CueR,rxn(ic));
                [rhoS,pvalS]=corr(SPR,rxn(ic));
            else
                rhoC =NaN; pvalC = NaN; rhoS = NaN, pvalS=NaN;
            end
            plot(rxn(ia),1:length(E1),'Color','k', 'Linewidth', 2)
            shading flat
            set(gca,'Ydir','normal','Clim',[-2 5]);colormap  parula;
            
            tt=[];
            if pvalC<0.05
                tt=['RC=' num2str(rhoC)];
            end
            if pvalS<0.05
                tt=[tt 'RS=' num2str(rhoS)];
                
            end
            title(tt)
            
            Results(h).rxn=rxn(ic);
            Results(h).CR=CueR;
            Results(h).SPR=SPR;
            Results(h).MaxZ = MaxZ;
            Results(h).rhoCpearson=rhoC;
            Results(h).pvalCpearson=pvalC;
            Results(h).rhoSpearson=rhoS;
            Results(h).pvalSpearson=pvalS;
            if ~isempty(CueR)
                [rhoC,pvalC]=corr(CueR,rxn(ic),'type','Spearman');
                [rhoS,pvalS]=corr(SPR,rxn(ic),'type','Spearman');
            else
                rhoC =NaN; pvalC = NaN; rhoS = NaN, pvalS=NaN;
            end
            Results(h).rhoCspearman=rhoC;
            Results(h).pvalCspearman=pvalC;
            Results(h).rhoSspearman=rhoS;
            Results(h).pvalSspearman=pvalS;
            Results(h).Session=tmp(fi).name;
            Results(h).Channel=c;
            Results(h).Locations = locLabels{c};
             h = h+1;
        end
     saveas(fh, sprintf('%s%sSingleTrialDetection%s%sSession%d.bmp',figDir,filesep,filesep,data.SubjectID,fi),'bmp');
     close(fh);
    
    end
end

save([savedDataDir filesep group '_SingleTrialActivity.mat']);