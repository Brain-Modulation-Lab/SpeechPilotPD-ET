function [R, z]=clus_z2(input,surr)
msurr=mean(reshape(surr,[],1));
stdsurr=std(reshape(surr,[],1));

surrz=(surr-msurr)./stdsurr;
% critzp=quantile(reshape(surrz,[],1),1-0.05);
critzp=1.64;

surrclusz=zeros(size(surr,2),1);
for s=1:size(surr,2)
    su=surrz(:,s);
    Psurrclus=bwconncomp(bsxfun(@times,su,su>critzp));
    if Psurrclus.NumObjects~=0
        Parea=cellfun(@(x) sum(su(x)),Psurrclus.PixelIdxList);
        Pmax=max(Parea);
    else Pmax=0;
    end
    
    surrclusz(s)= Pmax;
end

surrclusz=sort(surrclusz,'ascend');

z=(input-msurr)/stdsurr;
R.corrz=zeros(size(z));

CCP= bwconncomp(bsxfun(@times,z,z>critzp));
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
    Psigp=1-(dsearchn(surrclusz,clust_infoP')./length(surrclusz));
    Psigc=Psigp<0.05;
    Pidx=vertcat(CCP.PixelIdxList(Psigc));
    Psigp=Psigp(Psigc);
    Pz=clust_infoP(Psigc);
else
    Psigp=[];
    Pidx={};
    Pz=[];
end

R.sigz=Pz;
R.sigp=Psigp;
idx=vertcat(Pidx{:});
R.corrz(idx)=z(idx);
R.idx=Pidx;

 
        
end
