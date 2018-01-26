function [mi,amp_ph,zmi,avg,SD]=cfcMI5(ph,amp,nbin,niter,parallel)
%[mi,amp_ph,zmi,avg,SD]=cfcMI4(ph,amp,nbin,niter,parallel)
%
%computes strength of cross-frequency coupling using modulation index from 
%(Tort,2010) on each column vector in ph with all column vectors in amp;
%also has added option to return z-score of mi values - null distribution 
%is generated by iteratively circularly shifting the amplitude time series
%relative to phase and computing mi (for each phase-amplitude pair)
%
%note! zscoring is computationally intensive 
%
%
%INPUTS:
%-pi <= all(ph) <= pi;
%
%all(amp) >= 0;
%
%nbin=number of bins used to segment 2*pi radians (default=32);
%
%niter=number of random shifting iterations used to compute the null
%distribution for z-scoring (pass 0 to bypass z-scoring; default=0); 
%
%parallel: if ==1 then parallelizes computation
%           if ==0 then no parfor loops used
%
%
%OUTPUTS:
%mi=2D matrix of modulation index values (between 0 and 1) for all
%crosses of amp and ph column vectors 
%
%amp_ph=distribution of amplitude by phase bin from which coupling was 
%calculated (amp_ph(i,j,:) corresponds to the distribution for  mi(i,j));
%
%zmi=matrix of z-values for z-scored mi (zmi(i,j) corresponds to mi(i,j));
%
%
%TAW_070814  Modified: ANA_020115 TAW_062415

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
bins=linspace(-pi,pi,nbin+1);
bins=[-inf bins(2:end-1) inf];
P=zeros(nbin,ac);
maxE=log2(nbin);imaxE=1/maxE;
mi=zeros(ac,pc);
amp_ph=zeros(ac,pc,nbin);
whichbin=zeros(pr,pc);

%loop through all phase timeseries to get actual mi
for n=1:pc
    %bin amp into phase bins
    [~,whichbin(:,n)]=histc(ph(:,n),bins);
    for j=1:nbin
        P(j,:)=mean(amp(whichbin(:,n)==j,:),1);
    end
    %correct for zero-bins
    P(isnan(P))=0;
    
    %store amplitude by phase distribution
    amp_ph(:,n,:)=P';
    
    %normalize P into pdf
    P=P./repmat(sum(P,1),nbin,1);
    
    %compute modulation index
    P=P.*log2(P);
    P(isnan(P))=0;
    mi(:,n)=(maxE+sum(P,1))*imaxE;
end

%z-score mi values 
if niter>0
    zmi=zeros(ac,pc);
    avg=zmi;
    SD=zmi;
    shift=randi(ar,niter,1);
    
    %single-threaded
    if parallel<1
        %loop through amplitudes
        for na=1:ac
            %circularly shift surrogate amplitudes
            samp=repmat(amp(:,na),1,niter);
            samp=truffle_shuffle(samp,shift,niter);
            %loop through phases
            for np=1:pc
                Psurr=gensurrg(samp,whichbin(:,np),nbin,niter);
                Psurr=Psurr./repmat(sum(Psurr,1),nbin,1);
                %compute modulation index
                Psurr=Psurr.*log2(Psurr);
                Psurr(isnan(Psurr))=0;
                nullmi=(maxE+sum(Psurr,1))*imaxE;
                %z-score actual mi
                avg(na,np)=mean(nullmi);
                SD(na,np)=std(nullmi);
                zmi(na,np)=(mi(na,np)-avg(na,np))/SD(na,np);
            end
        end
        
    %multi-threaded
    elseif parallel>=1
        %loop through amplitudes
        parfor na=1:ac
            %circularly shift surrogate amplitudes
            samp=repmat(amp(:,na),1,niter);
            samp=truffle_shuffle(samp,shift,niter);
            %loop through phases
            for np=1:pc
                Psurr=gensurrg(samp,whichbin(:,np),nbin,niter);
                %correct for zero-bins
                Psurr(isnan(Psurr))=0;
                Psurr=Psurr./repmat(sum(Psurr,1),nbin,1);
                %compute modulation index
                Psurr=Psurr.*log2(Psurr);
                Psurr(isnan(Psurr))=0;
                nullmi=(maxE+sum(Psurr,1))*imaxE;
                %z-score actual mi
                avg(na,np)=mean(nullmi);
                SD(na,np)=std(nullmi);
                zmi(na,np)=(mi(na,np)-avg(na,np))/SD(na,np);
            end
        end
    end
    
end
end

function samp=truffle_shuffle(samp,shift,niter)
for n=1:niter
    samp(:,n)=circshift(samp(:,n),shift(n),1);
end
samp=samp';
end

function [Psurr]=gensurrg(samp,whichbin,nbin,niter)
Psurr=zeros(nbin,niter);
for j=1:nbin
    Psurr(j,:)=mean(samp(:,(whichbin==j)),2);
    %correct for zero-bins
    Psurr(isnan(Psurr))=0;
end
end