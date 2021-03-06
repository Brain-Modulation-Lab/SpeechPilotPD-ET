subjects=arrayfun(@(x) ['DBS' num2str(2000+x)],1:15,'Uni',0);
fq=[2:4:200]';
stat.voxel_pval=0.05; stat.cluster_pval=0.05; stat.surrn=1;

load('/Users/pirnia/Dropbox (Brain Modulation Lab)/Functions/Ahmad/Filters/bandpassfilters.mat')
load('/Users/pirnia/Dropbox (Brain Modulation Lab)/Functions/Ahmad/Filters/highoass_2Hz_fs1200.mat')   
pad=5*1200;
Cond={'Cue','Onset'};
freq={'delta','theta','alpha','beta1','beta2','Gamma','Hgamma'};
pth=['/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings'];
if ispc
    sl='\';
else
    sl='/';
end
%if ref =0 no common average reference 
ref=1;
 h=1;
Results=[];
for s=1:length(subjects)
    tmp=dir([pth sl subjects{s} sl 'Preprocessed Data' sl 'DBS*.mat']);
    for fi=1:length(tmp)
        data=load([pth sl subjects{s} sl 'Preprocessed Data' sl tmp(fi).name]);
        % highpass filter at 2Hz to remove heartbeat 
        input=filtfilt(hpFilt,data.macro);
        % common average reference 
        if ref
        input= bsxfun(@minus,input,mean(input,2));
        end
        
        ch=size(input,2);
        reject=[find(isnan(data.trials.SpOnset))' find(isnan(data.trials.SpEnd))' data.trials.ResponseReject.all'];
        if length(data.trials.BaseRejectNoise)<10
            reject=unique([reject , data.trials.BaseRejectNoise']);
        else 
            reject=unique(reject);
        end
        trIndx=setdiff(1:60,reject);
        % getting time stamps in seconds
        E0=data.trials.BaseFwd(setdiff(1:60,reject));
        E1=data.trials.BaseBack(setdiff(1:60,reject)); %word presentation
        E2=data.trials.SpOnset(setdiff(1:60,reject));
        E3=data.trials.SpEnd(setdiff(1:60,reject));
        % automatic rejection of of bad trials based on the voltage of the
        % signal
        [artifact]=auto_reject(input,E1,1200);
        artifact=unique(horzcat(artifact{:}));
        E0(artifact)=[];    E1(artifact)=[];   E2(artifact)=[];     E3(artifact)=[];
        trIndx(artifact)=[];
        nt=length(E1);
        for c=1:length(Cond)
            switch Cond{c}
                case 'Cue'
                    prestim=round(0.5*data.nfs);
                    poststim=round(mean(E2-E1)*data.nfs);
                    E2use=E1;
                case 'Onset'
                    prestim=round(mean(E2-E1)*data.nfs);
                    poststim=round(1+mean(E3-E2)*data.nfs);
                    E2use=E2;
            end
        
        
%         bdur=round(min(E1-E0)*data.nfs);
        bdur=round(1*data.nfs);

        [~,Results(h).(Cond{c}).tr,Results(h).(Cond{c}).base]=calc_ERSP(input, data.nfs, fq,E2use, prestim/data.nfs, poststim/data.nfs, E1, 1,stat);
       %saving the parameters that were run
        Results(h).(Cond{c}).parameters={'prestim',prestim/data.nfs,'poststim',...
            poststim/data.nfs,'baselinedur',bdur/data.nfs,'TrialN',nt,...
            'trialsUsed',trIndx,'ChannelN',ch,'ComRef',ref};
        % make index to remove the trials from the signal
        trial=arrayfun(@(x) input(x-prestim-pad:x+poststim+pad,:),round(E2use*data.nfs),'Uni',0);
        trial=cat(2,trial{:});
        base=arrayfun(@(x) input(x-bdur-pad:x+pad,:),round(E1*data.nfs),'Uni',0);
        base=cat(2,base{:});
        
        for f=1:length(freq)
        eval(['theseeve=' freq{f} 'Filt;']);    
        % bandpass filter into appropriate band and remove the padding
        cmp_tr=hilbert(filtfilt(theseeve,trial));
        cmp_tr=cmp_tr(pad+1:end-pad,:);
        cmp_bs=hilbert(filtfilt(theseeve,base));
        cmp_bs=cmp_bs(pad+1:end-pad,:);
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

        % Rayleigh test see circstat toolbox 
        R = nt*Results(h).(Cond{c}).(freq{f}).IPC_tr;
        Results(h).(Cond{c}).(freq{f}).z_IPC = (R.^2) / nt;
        %  P-value for Rayleigh test 
        Results(h).(Cond{c}).(freq{f}).p_IPC = exp(sqrt(1+4*nt+4*(nt^2-R.^2))-(1+2*nt));
       
       % baseline IPC
        Results(h).(Cond{c}).(freq{f}).IPC_bs=cell2mat(arrayfun(@(x) abs(mean(cmp_bs(:,x:3:end),2)),1:ch,'Uni',0));
        
        
        end
        
        end
        Results(h).Session=tmp(fi).name;
       
        clearvars R cmp_tr cmp_bs input data reject E0 E1 
        h=h+1
        
   
    end
end
    save('Band_modulation_referenced-061117.mat','Results','-v7.3')
