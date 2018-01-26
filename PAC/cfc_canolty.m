function [mi]=cfc_canolty(ph,amp,fs,window)
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


mi=zeros(ar,ac,pc); 
ph=exp(bsxfun(@times,1i,ph));

parfor np=1:pc
    mi(:,:,np)=reshape((smooth(bsxfun(@times,amp,ph(:,np)),window)),[],ac);

end



end
