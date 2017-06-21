function [zsc,tr,base,sr]=calc_ERSP(signal, fs, fq,Events, prestim, poststim, baseline, baseline_dur,stat)

% Events,baseline, baseline_dur prestim and poststim are in seconds


if size(signal,1)>size(signal,2)
    signal=signal';
end
ch=size(signal,1);
n=length(signal);
Events=round(Events*fs);
prestim=round(prestim*fs);
poststim=round(poststim*fs);
baseline=round(baseline*fs);
baseline_dur=round(baseline_dur*fs);

bind=[];
for b=1:length(baseline)
    bind=cat(2,bind,baseline(b)-baseline_dur:baseline(b));
end
tind=[];
for t=1:length(Events)
    tind=cat(2,tind,Events(t)-prestim:Events(t)+poststim);
end

dx=size(fq,1);    dy=length(tind)/length(Events);   dz=length(Events);
dyb=length(bind)/length(baseline);   dzb=length(baseline);
sr=zeros(dx,dy,stat.surrn,ch);
sr=[];
parfor c=1:ch
    complex=fast_wavtransform(fq,signal(c,:),fs,7);
    
    tr(:,:,:,c)=reshape(complex(tind,:)',dx,dy,dz);
    base(:,:,:,c)=reshape(complex(bind,:)',dx,dyb,dzb);
    [sr(:,:,:,c)]=whysorandom(complex,dx,dy,dz,n,stat);
    fprintf(sprintf('\n     wavtransf %d / %d',c,ch))
end
clearvars signal
zsc=zeros(dx,dy,ch);

for i=1:ch
    x=mean(abs(tr(:,:,:,i)),3); %trial avgs
    y=mean(abs(base(:,:,:,i)),3);
    zsc(:,:,i)=bsxfun(@rdivide,bsxfun(@minus,x,mean(y,2)),std(y,0,2));
end
end

function [sr]=whysorandom(complex,dx,dy,dz,n,stat)
    sr=zeros(dx,dy,stat.surrn);
    for s=1:stat.surrn
        sind=[];
        sevents=randperm(n-1-dy,dz);
        sevents(sevents<=dy)=sevents(sevents<=dy)+dy;
        for t=1:length(sevents)
            sind=cat(2,sind,round(sevents(t)-((dy-1)/2)):round(sevents(t)+((dy-1)/2)));
        end

        sr(:,:,s)=single(mean(reshape(complex(sind,:)',dx,dy,dz),3));

    end
end
