function [pac_z,erpac,pac_sig]=erpac_trial(signal,fs,ampfq,phfq,Events,prestim,poststim,surrn,r)
if size(signal,1)>size(signal,2)
    signal=signal';
end
ch=size(signal,1);

Events=round(Events*fs/r);
prestim=round(prestim*fs/r);
poststim=round(poststim*fs/r);
for f=1:size(ampfq,1)
    amp(:,f,:)=reshape(smooth(abs(hilbert(eegfilt(signal,fs,ampfq(f,1),ampfq(f,2))')),50),[],ch);
end
amp=squeeze(num2cell(downsample(amp,r),[1 2]));

for f=1:size(phfq,1)
    ph(:,f,:)=reshape(angle(hilbert(eegfilt(signal,fs,phfq(f,1),phfq(f,2))')),[],ch);
end
ph=squeeze(num2cell(downsample(ph,r),[1 2]));

tind=[];
for t=1:length(Events)
    tind=cat(2,tind,Events(t)-prestim:Events(t)+poststim);
end

dy=length(tind)/length(Events);   dz=length(Events);
tramp=cellfun(@(x) reshape(x(tind,:)',length(ampfq),dy,dz),amp,'UniformOutput', false);
trph=cellfun(@(x) reshape(x(tind,:)',length(phfq),dy,dz),ph,'UniformOutput', false);
[np, na]=meshgrid(1:length(phfq),1:length(ampfq));

erpac=zeros(length(ampfq),length(phfq),dy,ch);
tic
parfor c=1:ch
    as=tramp{c};
    ps=trph{c};
    e{c}=arrayfun(@(x, y) circ_corrcl_AA(squeeze(ps(x,:,:)),squeeze(as(y,:,:)),2), np,na,'UniformOutput',false);
end

for c=1:ch
    for i=1:numel(np)
        erpac(na(i),np(i),:,c)=e{c}{na(i),np(i)};
    end
end
toc


for c=1:ch
    
    as=tramp{c};
    ps=trph{c};
    parfor_progress(surrn);
    tic
    parfor s = 1:surrn
        sas=as(:,:,randperm(length(Events)));
        surr{s}=arrayfun(@(x, y) circ_corrcl_AA(squeeze(ps(x,:,:)),squeeze(sas(y,:,:)),2), np,na,'UniformOutput',false);
        parfor_progress;
    end
    parfor_progress(0);
    tic
    for s=1:surrn
        for i=1:numel(np)
            surrd(na(i),np(i),:,s)=surr{c}{na(i),np(i)};
        end
    end
    toc
    surrm(:,:,:,c)=mean(surrd,4);
    surrstd(:,:,:,c)=std(surrd,0,4);
    toc
end

% z-score
pac_z = (erpac-surrm)./surrstd;


pac_sig = z2p(pac_z); % p-value from z-score

end
