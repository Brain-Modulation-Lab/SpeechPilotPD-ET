function [plMI,limits,Surrdis,id]=calc_plMI(ph,amp,nbin,niter,Qup,Qlo)

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

bins=linspace(-2*pi,2*pi,nbin+1);
bins=[-inf bins(2:end-1) inf];
pccomb=(pc^2-pc)/2;
plMI12=zeros(nbin,pccomb);plMI21=plMI12;
whichbin=zeros(pr,pccomb);

% calculate the channel phdiff and find the unique combinations
phdif=zeros(pr,pccomb);
k1=pc-1;k2=0;
r=[];c=[];
for i=1:pc
phdif(:,(1:k1)+((k2)))=bsxfun(@minus,ph(:,i),(ph(:,i+1:pc)));
r=[r; repmat(i,pc-i,1)];
c=[c; (i+1:pc)'];
k2=k1+k2;
k1=k1-1;
end
%loop through all phase timeseries to get actual mi
id=[r c];
for n=1:pccomb
[~,whichbin(:,n)]=histc(phdif(:,n),bins);
end



for n=1:pccomb
    %bin amp into phase bins
    for j=1:nbin
        plMI12(j,n)=median(amp(whichbin(:,n)==j,r(n)),1);
        plMI21(j,n)=median(amp(whichbin(:,n)==j,c(n)),1);
        
    end
     
end
Psurr12=zeros(nbin,niter,'gpuArray');
Psurr21=zeros(nbin,niter,'gpuArray');

UpQ=zeros(nbin,pccomb);
LpQ=zeros(nbin,pccomb);
Surrdis=cell(pccomb,2);
%z-score mi values
if niter>0
  
    shift=randperm(ar,niter)';
    
        %loop through amplitudes
        for np=1:pccomb   

            sph=repmat(ph(:,r(np)),1,niter);
            sph=truffle_shuffle(sph,shift,niter);
            sph=bsxfun(@minus,sph,ph(:,c(np)));
            [~,~,swhichbin]=histcounts(sph,bins);
            swhichbin=gpuArray(int16(swhichbin));
            samp12=repmat(gpuArray(amp(:,r(np))),1,niter);
            samp21=repmat(gpuArray(amp(:,c(np))),1,niter);
            for j=1:nbin
                x=bsxfun(@times,samp12,(swhichbin==j));
                x(x==0)=NaN;
                Psurr12(j,:)=nanmean(x,1);
                 x=bsxfun(@times,samp21,(swhichbin==j));
                x(x==0)=NaN;
                Psurr21(j,:)=nanmean(x,1);
            end
UpQ12(:,np)=quantile(Psurr12,Qup,2);
LpQ12(:,np)=quantile(Psurr12,Qlo,2);
UpQ21(:,np)=quantile(Psurr21,Qup,2);
LpQ21(:,np)=quantile(Psurr21,Qlo,2);
Surrdis{np,1}=gather(Psurr12);
Surrdis{np,2}=gather(Psurr21);

        end
        
plMI=[{plMI12} {plMI21}];
limits=  [{UpQ12} {LpQ12}; {UpQ21} {LpQ21}];
    
end
end

function sph=truffle_shuffle(sph,shift,niter)
for n=1:niter
    sph(:,n)=circshift(sph(:,n),shift(n),1);
end

end
