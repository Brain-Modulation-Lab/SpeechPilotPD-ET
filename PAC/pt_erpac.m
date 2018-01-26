function [ph]=pt_erpac(signal, fs, fq,Events, prestim, poststim, baseline, baseline_dur,ds)
if size(signal,1)>size(signal,2)    
    signal=signal';
end
ch=size(signal,1);

Events=round(Events*fs/ds);
prestim=round(prestim*fs/ds);
poststim=round(poststim*fs/ds);
baseline=round(baseline*fs/ds);
baseline_dur=round(baseline_dur*fs/ds);


parfor f=1:size(fq,1)
complex(:,f,:)=hilbert(eegfilt(signal,fs,fq(f,1),fq(f,2))');
end
dx=size(fq,1);    dy=prestim+poststim+1;   dz=length(Events);

tr=zeros(dz,dy,dx);
ph=zeros(dz,dy*dx,ch);
for c=1:ch

for t=1:length(Events)
    tr(t,:,:)=complex(Events(t)-prestim:Events(t)+poststim,:,c);
end
ph(:,:,c)=angle(reshape(tr,dz,[]));
end

