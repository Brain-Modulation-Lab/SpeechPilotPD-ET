function [mi,zmi]=cfc_canolty_sliding(ph,amp,niter,fs,baseline,event)
% baseline is [start-time end-time] of baseline in seconds
% event is [start-time end-time] of event in seconds
% calculating the zmi for PAC based on canolty method using the mean and
% std of PAC of the baseline

ph=squeeze(ph);
[pr,pc]=size(ph);
if pc>pr
    ph=ph';
    tempr=pr;
    pr=pc;
    pc=tempr;
end
%orient amp
amp=squeeze(amp);
[ar,ac]=size(amp);
if ac>ar
    amp=amp';
    tempr=ar;
    ar=ac;
    ac=tempr;
end

t1=round(baseline(1)*fs:baseline(2)*fs);
t2=round(event(1)*fs:event(2)*fs);
iN=1./length(t1);

mi=zeros(length(t2),ac,pc); zmi=mi;
surr_mean=mi; surr_std=mi;

ph=exp(bsxfun(@times,1i,ph));

for np=1:pc
    mi(:,:,np)=reshape(abs(smooth(bsxfun(@times,amp(t2,:),ph(t2,np)),fs)),[],ac);
%     mi(:,:,np)=abs((bsxfun(@times,amp(t2,:),ph(t2,np))));

end

for na=1:ac

    samp=repmat(amp(t1,na),1,niter);
    shift=randi(length(t1),niter,1);
    
    samp=truffle_shuffle(samp,shift,niter);
    for np=1:pc
        
        misurr=abs(iN.*sum(bsxfun(@times,samp,ph(t1,np))));
        [m, s] = normfit(misurr');
        surr_mean(:,na,np)=repmat(m,length(t2),1);
        surr_std(:,na,np)=repmat(s,length(t2),1);
        
    end

end
zmi=(mi-surr_mean)./surr_std;

end

function samp=truffle_shuffle(samp,shift,niter)
for n=1:niter
    samp(:,n)=circshift(samp(:,n),shift(n),1);
end
end