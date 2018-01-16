function [ActOnset,ZBB]=single_trial_detection(signal,sr,base,trial,tlen,f2u) 
% single-trail activation based on Coon et al 2016

ch=size(signal,2);

BBFilt = designfilt('bandpassiir','StopbandFrequency1',f2u-10,'PassbandFrequency1',f2u-7.5,'PassbandFrequency2',f2u+7.5, ...
    'StopbandFrequency2',f2u+10,'StopbandAttenuation1',40,'PassbandRipple',0.01, ...
    'StopbandAttenuation2',40,'DesignMethod','butter','SampleRate',sr);

BB=abs(hilbert(filtfilt(BBFilt,signal)));

for i=1:ch
 BB(:,i)=smooth(BB(:,i),200);   
end
    

tn=length(trial);  % trial number
clearvars BBtr BBbase ZBB ZBBb
% define trials and baseline
for i=1:tn
    BBtr(:,i,:)=downsample(BB(round(trial(i)*sr):round(trial(i)*sr)+tlen,:),6);
    BBbase(:,i,:)=downsample(BB(round(base(i)*sr)-sr:round(base(i)*sr),:),6);
end
% z-score to baseline amp for all the trials
for i=1:ch
    baseline=BBbase(:,:,i);
    ZBB(:,:,i)=bsxfun(@rdivide, bsxfun(@minus, BBtr(:,:,i), mean(baseline(:))),std(baseline(:)));
    ZBBb(:,:,i)=bsxfun(@rdivide, bsxfun(@minus, BBbase(:,:,i), mean(baseline(:))),std(baseline(:)));
end

tl=size(BBtr,1);  % trial length
%% Activation detection using SNR method by Schalk et al. 1972
SNR=zeros(ch,1);
totVar=zeros(ch,1); mvar=totVar;
% total variance in BB amp (all time samples for all trials)
totVar=arrayfun(@(x) var(reshape(ZBB(:,:,x),[],1)),1:ch)';

% mean variance across trials in 50 ms nonoverlapping bins
binsize=0.05*sr;
bins=1:binsize:size(BBtr,1)-binsize;
for i=1:ch
    sig=ZBB(:,:,i);
    mvar(i)=mean(arrayfun(@(x) var(reshape(sig(x:x+binsize,:),[],1)),bins));
end
% SNR= divide total by mean variance
SNR=totVar./mvar;
% p-value of SNR by temporal shuffling of trial times and bootstrapping
% keep channels <=0.0001

surr=zeros(2000,1);
pval=zeros(ch,1);
for i=1:ch
    sig=ZBB(:,:,i);
    tmp=totVar(i);
    parfor s=1:2000
        Rndtr=arrayfun(@(x) circshift(sig(:,x),randperm(tl,1)),1:tn,'UniformOutput',0);
        Rndtr=cat(2,Rndtr{:});
        surr(s)=tmp/mean(arrayfun(@(x) var(reshape(Rndtr(x:x+binsize,:),[],1)),bins));
    end
    pval(i)=1-cdf('Normal',SNR(i),mean(surr),std(surr));
end
ch2keep=find(pval<0.01);
ch2keep=1;
%% Activity onset detection
if ~isempty(ch2keep)
thresh=1.7:0.05:6;

for i=1:length(ch2keep)
    dt=ZBB(:,:,ch2keep(i));
    db=ZBBb(:,:,ch2keep(i));
    for t=1:length(thresh)
        bdec=sum(arrayfun(@(x) any(db(:,x)>thresh(t)),1:tn));
        tdec=sum(arrayfun(@(x) any(dt(:,x)>thresh(t)),1:tn));
    detdiff(t)=tdec-bdec;
    end
    [~,mi]=max(detdiff);
    zthresh(i)=thresh(mi);
   tmp=arrayfun(@(x)  bwconncomp(dt(:,x)>zthresh(i)),1:tn,'UniformOutput',0);
   for i2=1:length(tmp)
       [detlen]=arrayfun(@(x) sum(dt(tmp{i2}.PixelIdxList{x},i2)),1:length(tmp{i2}.PixelIdxList));
       if isempty(detlen)
           ActOnset(i2,i)=NaN;
           
       else
           [~,mi]=max(detlen);
           ActOnset(i2,i)=tmp{i2}.PixelIdxList{mi}(1);
       end
       
   end
   
   tmp=arrayfun(@(x)  bwconncomp(db(:,x)>zthresh(i)),1:tn,'UniformOutput',0);
   for i2=1:length(tmp)
       [detlen]=arrayfun(@(x) sum(db(tmp{i2}.PixelIdxList{x},i2)),1:length(tmp{i2}.PixelIdxList));
       if isempty(detlen)
           ActOnsetb(i2,i)=NaN;
           
       else
           [~,mi]=max(detlen);
           ActOnsetb(i2,i)=tmp{i2}.PixelIdxList{mi}(1);
       end
       
   end
%     tmp=arrayfun(@(x) find(dt(:,x)>zthresh(i),1,'first'),1:tn,'UniformOutput',0);
%     tmp(cellfun(@isempty, tmp))={NaN};
%     ActOnset(:,i)=cell2mat(tmp);

% 
%     tmp=arrayfun(@(x) find(db(:,x)>zthresh(i),1,'first'),1:tn,'UniformOutput',0);
%     tmp(cellfun(@isempty, tmp))={NaN};
%     ActOnsetb(:,i)=cell2mat(tmp);
end

% surr=zeros(1000,1);
% for i=1:length(ch2keep)
%     Atn=sum(~isnan(ActOnset(:,i)));
%     Abn=sum(~isnan(ActOnsetb(:,i)));
%     
%     parfor s=1:1000
%         tmp=randi(2,Atn+Abn,1);
%         surr(s)=sum(tmp==1)-sum(tmp==2);
%     end
%     pvald(i)=1-cdf('Normal',Atn-Abn,mean(surr),std(surr));
% end
% ch2keep=ch2keep(pvald<=0.01);
% ActOnset(:,pvald>=0.01)=NaN;
else 
    ActOnset=NaN(tn,1);
end