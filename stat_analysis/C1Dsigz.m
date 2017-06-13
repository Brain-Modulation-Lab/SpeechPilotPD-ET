function  [idx,pval]=C1Dsigz(rho,rhos)
surr=cat(2,rhos{:});
surr(isnan(surr))=0;

msurr=mean(surr,2);
stdsurr=std(surr,0,2);
surr=bsxfun(@rdivide,bsxfun(@minus,surr,msurr),stdsurr);
surr(isnan(surr))=0;

critzp=quantile(surr,1-0.05,2);
critzn=quantile(surr,0.05,2);

surrclusz=[];

for s=1:size(surr,2)
    surrz=surr(:,s);
    
    Psurrclus=bwconncomp(bsxfun(@times,surrz,surrz>critzp));
    if Psurrclus.NumObjects~=0
        Parea=cellfun(@(x) sum(surrz(x)),Psurrclus.PixelIdxList);
        Pmax=max(Parea);
    else Pmax=0;
    end
    Nsurrclus=bwconncomp(bsxfun(@times,surrz,surrz<critzn));
    if Nsurrclus.NumObjects~=0
        Narea=(cellfun(@(x) sum(surrz(x)),Nsurrclus.PixelIdxList));
        Nmax=min(Narea);
    else Nmax=0;
    end
    
    surrclusz=[surrclusz; Pmax; Nmax];
    
    
    
    
end
surrclusz=sort(surrclusz,'ascend');


z=bsxfun(@rdivide,bsxfun(@minus,rho,msurr),stdsurr);
z(isnan(z))=0;
CCP= bwconncomp(bsxfun(@times,z,z>critzp));
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
    %     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=(1-(dsearchn(surrclusz,clust_infoP')./length(surrclusz)))*2;
    Psigc=Psigp<0.05;
    Pidx=vertcat(CCP.PixelIdxList(Psigc));
    Psigp=Psigp(Psigc);
else
    Psigp=[];
    Pidx={};
 
end
CCN= bwconncomp(bsxfun(@times,z,(z<critzn)));
if CCN.NumObjects~=0
    clust_infoN =cellfun(@(x) sum(z(x)), CCN.PixelIdxList);
    %     Nsigp=normcdf(clust_infoN,msurr,stdsurr);
    Nsigp=2*(dsearchn(surrclusz,clust_infoN')./length(surrclusz));
    Nsigc=Nsigp<0.05;

    Nidx=vertcat(CCN.PixelIdxList(Nsigc));
    Nsigp=Nsigp(Nsigc);
else
    Nsigp=[];
    Nidx={};
    
    
end
pval=[Psigp; Nsigp];
idx=vertcat(Pidx,Nidx);

 
        
end