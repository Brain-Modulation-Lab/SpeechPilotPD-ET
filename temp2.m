setDirectories; %platform specific locations 
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
subjectLists; %load lists of subjects
subjects = PD_subjects;
group = 'PD';

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
        data=load([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep tmp(fi).name],'Ecog','trials','nfs', 'badch','labels', 'EcogLabels','Side', 'SubjectID');
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
      
        reject=[find(isnan(data.trials.SpOnset))' find(isnan(data.trials.SpEnd))' data.trials.ResponseReject.all'];
        if length(data.trials.BaseRejectNoise)<10
            reject=unique([reject , data.trials.BaseRejectNoise']);
        else
            reject=unique(reject);
        end
        trIndx=setdiff(1:60,reject);
        E0=data.trials.BaseFwd(setdiff(1:60,reject));
        E1=data.trials.BaseBack(setdiff(1:60,reject));
        E2=data.trials.SpOnset(setdiff(1:60,reject));
        E3=data.trials.SpEnd(setdiff(1:60,reject));
        
        [artifact]=auto_reject2(input,E1,1200);
        artifact=unique(horzcat(artifact{:}));
        E0(artifact)=[];    E1(artifact)=[];   E2(artifact)=[];     E3(artifact)=[];
        trIndx(artifact)=[];
        nt=length(E1);
        tlen=round((0.5+max(E3-E1))*data.nfs);
        
        %% Calculate and plot the single trial response detection
        [ah, fh] = subplot_pete(ch, 1,'','', tmp(fi).name);
        fh.Position = [20 20 1000 1200]; % We want to make these big, then save them
        rxn=E2-E1;    [~,ia]=sort(rxn,'ascend');
        clearvars ZBB ActOnset
        ci = 1;
        for c=1:ch
            [ActOnset(:,c),ZBB(:,:,c)]=single_trial_detection(input(:,chUsed(c)),data.nfs,E1,E1,tlen,HgammaFilt);
            ic=~isnan(ActOnset(:,c));
            CueR=ActOnset(ic,c)/200;
            SPR=(E2(ic)-ActOnset(ic,c))/200;
            axes(ah(c));
            image(0:1/200:size(ZBB,1)/200,1:size(ZBB,2),ZBB(:,ia,c)','CDataMapping','scaled')
            hold on
            if sum(isnan(ActOnset(:,c)))~=length(ActOnset)
                scatter(ActOnset(ia,c)/200,1:length(E1),35,'*','k')
            end
            [rhoC,pvalC]=corr(CueR,rxn(ic));
            [rhoS,pvalS]=corr(SPR,rxn(ic));
            
            plot(rxn(ia),1:length(E1),'Color','k')
            shading flat
            set(gca,'Ydir','normal','Clim',[-5 10]);colormap  jet;
            
            tt=[];
            if pvalC<0.05
                tt=['RC=' num2str(rhoC)];
            end
            if pvalS<0.05
                tt=[tt 'RS=' num2str(rhoS)];
                
            end
            title(tt)
            
            Results(h).chan(ci).rxn=rxn(ic);
            Results(h).chan(ci).CR=CueR;
            Results(h).chan(ci).SPR=SPR;
            Results(h).chan(ci).rhoCpearson=rhoC;
            Results(h).chan(ci).pvalCpearson=pvalC;
            Results(h).chan(ci).rhoSpearson=rhoS;
            Results(h).chan(ci).pvalSpearson=pvalS;
            [rhoC,pvalC]=corr(CueR,rxn(ic),'type','Spearman');
            [rhoS,pvalS]=corr(SPR,rxn(ic),'type','Spearman');
            Results(h).chan(ci).rhoCspearman=rhoC;
            Results(h).chan(ci).pvalCspearman=pvalC;
            Results(h).chan(ci).rhoSspearman=rhoS;
            Results(h).chan(ci).pvalSspearman=pvalS;
            Results(h).chan(ci).Session=tmp(fi).name;
            Results(h).chan(ci).Channel=c;
            Results(h).chan(ci).Locations = locLabels{c};
            ci=ci+1;
            %                         set(gca,'Ydir','normal');colormap  jet;
        end
     saveas(fh, sprintf('%s%sSingleTrialDetection%s%sSession%d.bmp',figDir,filesep,filesep,data.SubjectID,data.Session),'bmp');
     close fh;
    end
end