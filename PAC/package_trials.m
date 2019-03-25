function [tr,base]=package_trials(signal, fs, fq,Events, prestim, poststim, baseline, baseline_dur,ds,transform)
if size(signal,1)>size(signal,2)    
    signal=signal';
end
ch=size(signal,1);

Events=round(Events*fs/ds);
prestim=round(prestim*fs/ds);
poststim=round(poststim*fs/ds);
baseline=round(baseline*fs/ds);
baseline_dur=round(baseline_dur*fs/ds);
if strcmp(transform,'none')
    signal=squeeze(num2cell(downsample(signal',ds),[1]));
    bind=[];
for b=1:length(baseline)
    bind=cat(2,bind,baseline(b)-baseline_dur:baseline(b));    
end
tind=[];
for t=1:length(Events)
    tind=cat(2,tind,Events(t)-prestim:Events(t)+poststim);
end

dx=length(tind)/length(Events);   dz=length(Events);
tr=cellfun(@(x) reshape(x(tind,:)',dx,dz),signal,'UniformOutput', false);
dxb=length(bind)/length(baseline);   dzb=length(baseline);
base=cellfun(@(x) reshape(x(bind,:)',dxb,dzb),signal,'UniformOutput', false);
else

switch transform
    case 'wavelet'
parfor c=1:ch
complex(:,:,c)=fast_wavtransform(fq,signal(c,:),fs,6);
end
complex=squeeze(num2cell(downsample(complex,ds),[1 2]));
    case 'hilbert'
parfor f=1:size(fq,1)
complex(:,f,:)=hilbert(eegfilt(signal,fs,fq(f,1),fq(f,2))');
end
complex=squeeze(num2cell(downsample(complex,ds),[1 2]));

end
bind=[];
for b=1:length(baseline)
    bind=cat(2,bind,baseline(b)-baseline_dur:baseline(b));    
end
tind=[];
for t=1:length(Events)
    tind=cat(2,tind,Events(t)-prestim:Events(t)+poststim);
end

dx=size(fq,1);    dy=length(tind)/length(Events);   dz=length(Events);
tr=cellfun(@(x) reshape(x(tind,:)',dx,dy,dz),complex,'UniformOutput', false);
dyb=length(bind)/length(baseline);   dzb=length(baseline);
base=cellfun(@(x) reshape(x(bind,:)',dx,dyb,dzb),complex,'UniformOutput', false);
end
