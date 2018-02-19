function [ActOnset,ZBB]=single_trial_detection(signal,sr,base,trial,trialend,tlen,filt2u) 
% single-trial activation based on Coon et al 2016
% Signal - Dimensions: Time - only accepts a single vector signal
% representing a continuously sampled trace at sr. Individual trials should not be
% separated
% SR - sampling rate
% base - baseline data vector
% trial - times of the trial starts for each trial
% trialend - times of the trials ends for each trial
% tlen - trial length
% filt2u - The filter object that you want to use
% Return values: 
% ActOnset - The detected activity onset indices 
% ZBB - the Z-scored activities, 6x downsampled to 200Hz sample rate from
% 1.2kHz input

ch=size(signal,2);

% BBFilt = designfilt('bandpassiir','StopbandFrequency1',f2u-10,'PassbandFrequency1',f2u-7.5,'PassbandFrequency2',f2u+7.5, ...
%     'StopbandFrequency2',f2u+10,'StopbandAttenuation1',40,'PassbandRipple',0.01, ...
%     'StopbandAttenuation2',40,'DesignMethod','butter','SampleRate',sr);

BB=abs(hilbert(filtfilt(filt2u,signal)));

for i=1:ch
 BB(:,i)=smooth(BB(:,i),200);   
end
    
ds = 6; %downsampling factor necessary to get to 200 Hz (5ms) binning of responses
tn=length(trial);  % trial number
clearvars BBtr BBbase ZBB ZBBb
BBtr = NaN*zeros(ceil(tlen/ds), tn);
% define trials and baseline
for i=1:tn
    % messy, but need to figure out where each trial should end to censor data afterwards
    if ~isnan(trialend(i))
        tl = trialend(i) - trial(i);
    elseif i<tn
        tl = trial(i+1) - trial(i);
    else
        tl = tlen/sr;
    end
    tsamp = round(trial(i)*sr);
    BBtr(:,i,:)=downsample(BB(tsamp:tsamp+tlen-1,:),ds); %tr defines trials
    BBtr(ceil(tl*sr/ds):end, i,:) = NaN; 
    BBbase(:,i,:)=downsample(BB(round(base(i)*sr)-sr:round(base(i)*sr),:),ds); % defines a trial baseline as 1 sec prior to the times in base
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
       
    end
    
else
    ActOnset=NaN(tn,1);
end
