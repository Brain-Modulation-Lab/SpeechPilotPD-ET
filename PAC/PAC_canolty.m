function [mi,zmi]=PAC_canolty(ph,amp,niter)
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

iN=1./ar;
mi=zeros(ac,pc); 
ph=exp(bsxfun(@times,1i,ph));

for np=1:pc
    mi(:,np)=abs(iN*sum(bsxfun(@times,amp,ph(:,np)),1));

end

for na=1:ac
    
    samp=repmat(amp(:,na),1,niter);
    shift=randi(ar,niter,1);
    
    samp=truffle_shuffle(samp,shift,niter);
    for np=1:pc
        
        misurr=abs(iN.*sum(bsxfun(@times,samp,ph(:,np))));
        [m(na,np), s(na,np)] = normfit(misurr');
        
        
    end
    
end
zmi=(mi-m)./s;


end


function samp=truffle_shuffle(samp,shift,niter)
for n=1:niter
    samp(:,n)=circshift(samp(:,n),shift(n),1);
end
end