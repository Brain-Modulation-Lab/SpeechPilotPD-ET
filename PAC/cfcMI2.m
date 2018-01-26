function [mi,amp_ph,zmi]=cfcMI2(ph,amp,nbin,niter)
%[mi,amp_ph,zmi]=cfcMI(ph,amp,nbin,niter,saveTimeorRAM)
%
%computes strength of cross-frequency coupling using modulation index from 
%(Tort,2010) on each column vector in ph with all column vectors in amp;
%also has added option to return z-score of mi values - null distribution 
%is generated by iteratively circularly shifting the amplitude time series
%relative to phase and computing mi (for each phase-amplitude pair)
%
%note! zscoring is computationally intensive since mi is computed
%niter*size(ph,2)*size(amp,2) # of times thus parfor is used to reduce time
%
%
%-pi <= all(ph) <= pi;
%
%all(amp) >= 0;
%
%nbin=number of bins used to segment 2*pi radians (default=32);
%
%niter=number of random shifting iterations used to compute the null
%distribution for z-scoring (pass 0 to bypass z-scoring; default=0); 
%
%mi=2D matrix of modulation index values (between 0 and 1) for all
%crosses of amp and ph column vectors [mi(end,1)=mi value for ph(1) and 
%amp(1)]; 
%
%amp_ph=distribution of amplitude by phase bin from which coupling was 
%calculated (amp_ph(i,j,:) corresponds to the distribution for  mi(i,j));
%
%zmi=matrix of z-values for z-scored mi (zmi(i,j) corresponds to mi(i,j));
%
%saveTimeorRAM=allows the user to further preference implementation of 
%zscoring computation to either increase speed or save RAM 
%(1==speed; 2==RAM; default=1); 
%
%
%TAW_070814  Modified ANA_020115

% tic
%orient ph
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
%initialize optional inputs and other variables
if exist('nbin','var')==0
    nbin=32;
end
if exist('niter','var')==0
    niter=0;
end
if exist('saveTimeorRAM','var')==0 || saveTimeorRAM<1 || saveTimeorRAM>2
    saveTimeorRAM=1;
end
bins=linspace(-pi,pi,nbin+1);
bins=[-inf bins(2:end-1) inf];
P=zeros(nbin,ac);
maxE=log2(nbin);
mi=zeros(ac,pc);
amp_ph=zeros(ac,pc,nbin);

%loop through all phase timeseries to get actual mi
for n=1:pc
    
    %bin amp into phase bins
    [~,whichbin]=histc(ph(:,n),bins);
    for j=1:nbin
        P(j,:)=mean(amp(whichbin==j,:),1);
    end
    
    %store amplitude by phase distribution
    amp_ph(:,n,:)=P';
    
    %normalize P into pdf
    P=P./(ones(nbin,1)*sum(P,1));
    
    %compute modulation index
    mi(:,n)=(maxE+sum(P.*log2(P),1))/maxE;
end



%z-score mi values



s=size(amp,1);
zmi=zeros(ac,pc);
% 
Psurr=zeros(nbin,niter);
parfor np=1:pc
%     shift=ceil(rand(niter,1)*pr);
    shift=randperm(s,niter)';
    [~,whichbin]=histc(ph(:,np),bins);
 

for na=1:ac
samp=repmat(amp(:,na),1,niter);


for n=1:niter
samp(:,n)=circshift(samp(:,n),shift(n),1);
end
% samp=gpuArray(samp);

[Psurr]=gensurrg(samp,whichbin,nbin,niter);


Psurr=Psurr./(ones(nbin,1)*sum(Psurr,1));
    
        %compute modulation index
        nullmi=(maxE+sum(Psurr.*log2(Psurr),1))/maxE;
        
        %z-score actual mi
        zmi(na,np)=(mi(na,np)-mean(nullmi))/std(nullmi);
end

end
% toc
% figure
% pcolor(zmi); set(gca,'clim',[0,10]); title(num2str(toc));
end
function [Psurr]=gensurrg(samp,whichbin,nbin,niter)

for j=1:nbin
  
Psurr(j,:)=mean(reshape(samp((whichbin==j),:),[],niter),1);
end

end
