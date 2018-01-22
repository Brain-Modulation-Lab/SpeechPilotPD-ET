subjects=arrayfun(@(x) ['DBS' num2str(2000+x)],1:15,'Uni',0);
fq=[40:3:200]';
stat.voxel_pval=0.05; stat.cluster_pval=0.05; stat.surrn=1;

load('/Users/ahmadalhourani/Dropbox (Brain Modulation Lab)/Functions/Ahmad/Filters/bandpassfilters.mat')
load('/Users/ahmadalhourani/Dropbox (Brain Modulation Lab)/Functions/Ahmad/Filters/highoass_2Hz_fs1200.mat')   
addpath(genpath('/Users/ahmadalhourani/Dropbox (Brain Modulation Lab)/Functions/Ahmad/'));
if ispc
    sl='\';
    pth=['Z:\Electrophysiology_Data\DBS_Intraop_Recordings'];

else
    sl='/';
    pth=['/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings'];

end
 h=1;
Results=[];
for s=1:length(subjects)
    tmp=dir([pth sl subjects{s} sl 'Preprocessed Data' sl 'DBS*.mat']);
    for fi=1:length(tmp)
        data=load([pth sl subjects{s} sl 'Preprocessed Data' sl tmp(fi).name],'macro','trials','nfs');
        input=filtfilt(hpFilt,data.macro);
  
        ch=size(input,2);
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
    

        [~,tr,base]=calc_ERSP(input, data.nfs, fq,E2, 0.5, 1, E1, 1,stat);
        tr=abs(tr).^2; base=abs(base).^2;
        z=bsxfun(@rdivide, bsxfun(@minus, tr, mean(base,2)),std(base,0,2));
        t=squeeze(mean(z,3)./(std(z,0,3)/sqrt(size(z,3))));
        CC=arrayfun(@(x) bwconncomp(t(:,:,x)>2),1:ch,'Uni',0);
        for i=1:ch
        tmp2=t(:,:,i);
        ii=cell2mat(cellfun(@(x) sum(tmp2(x)),CC{i}.PixelIdxList,'Uni',0));
        [clusz(i), iclus(i)]=max(ii);   
        [~, ipx]=max(tmp2(CC{i}.PixelIdxList{iclus(i)}));
        [ro,~]=ind2sub(size(tmp2),CC{i}.PixelIdxList{iclus(i)}(ipx));
        f2u(i)=fq(ro);
        end
        
        tlen=round((0.5+max(E3-E1))*data.nfs);

        rxn=E2-E1;    [~,ia]=sort(rxn,'ascend');
        H=figure;
        clearvars ZBB ActOnset
        for c=1:ch
            
            [ActOnset(:,c),ZBB(:,:,c)]=single_trial_detection(input(:,i),data.nfs,E1,E1,tlen,70);
            ic=~isnan(ActOnset(:,c));
            CueR=ActOnset(ic,c)/200;
            SPR=(E2(ic)-ActOnset(ic,c))/200;
            subplot(1,ch,c)
            image(0:1/200:size(ZBB,1)/200,1:size(ZBB,2),ZBB(:,ia,c)','CDataMapping','scaled')
            hold on
            if sum(isnan(ActOnset(:,c)))~=length(ActOnset)
            scatter(ActOnset(ia,c)/200,1:length(E1),35,'*','k')
            end
            [rhoC,pvalC]=corr(CueR,rxn(ic));
            [rhoS,pvalS]=corr(SPR,rxn(ic));
            Results(h).rxn=rxn(ic);
            Results(h).CR=CueR;
            Results(h).SPR=SPR;
            Results(h).rhoCpearson=rhoC;
            Results(h).pvalCpearson=pvalC;
            Results(h).rhoSpearson=rhoS;
            Results(h).pvalSpearson=pvalS;
            [rhoC,pvalC]=corr(CueR,rxn(ic),'type','Spearman');
            [rhoS,pvalS]=corr(SPR,rxn(ic),'type','Spearman');
            Results(h).rhoCspearman=rhoC;
            Results(h).pvalCspearman=pvalC;
            Results(h).rhoSspearman=rhoS;
            Results(h).pvalSspearman=pvalS;
            Results(h).Session=tmp(fi).name;
            Results(h).Channel=c;
            h=h+1;
            plot(rxn(ia),1:length(E1),'Color','k')
            shading flat
            set(gca,'Ydir','normal','Clim',[-5 5]);colormap  jet;
            
            tt=[];
            if pvalC<0.05
              tt=['RC=' num2str(rhoC)];      
            end
            if pvalS<0.05
              tt=[tt 'RS=' num2str(rhoS)];
              
            end
            title(tt)
%                         set(gca,'Ydir','normal');colormap  jet;

        end
     suptitle(tmp(fi).name)     
savefig(H,['/Users/ahmadalhourani/Desktop/speech_figs/' tmp(fi).name(1:end-4) ])
close all
    end
end

save(['/Users/ahmadalhourani/Desktop/speech_figs/aggregate_results.mat' ])


