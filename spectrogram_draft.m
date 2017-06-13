function [ptr, pbase,time]=spectrogram_draft(signal,fs,Events, prestim, poststim, baseline,baseline_dur,winlen,fq)
if size(signal,2)>size(signal,1)    
    signal=signal';
end

ch=size(signal,2);
Events=round(Events*fs);
prestim=round(prestim*fs);
poststim=round(poststim*fs);
baseline=round(baseline*fs);
baseline_dur=round(baseline_dur*fs);
signal=squeeze(num2cell(signal,1));

nt=length(Events);
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
clearvars s sb
for i=1:ch

x=tr{i};
parfor t=1:nt
[s(:,:,t),~,tmp(:,t)]= spectrogram(x(:,t),hann(winlen*fs),(winlen*fs)*.8,fq,fs); 
end
time=tmp(:,1);
ptr{i}=abs(s);

x=base{i};
parfor t=1:nt
[sb(:,:,t)]= spectrogram(x(:,t),hann(winlen*fs),(winlen*fs)*.8,fq,fs); 
end
pbase{i}=abs(sb);
end
% 
% 
% figure
% for i=1:ch
% 
% m=mean(pbase{i},2);
% s=std(pbase{i},0,2);
% z{i}=mean(bsxfun(@rdivide, bsxfun(@minus,ptr{i},m),s),3);   
% subplot(1,3,i)
% contourf(t1-1,f,z{i},25,'LineColor','none')
% colormap jet; 
% set(gca,'Ydir','normal')
% end
% 
