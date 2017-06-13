function [tst,R,z]=ERP_stat_MEG(sig1,sig2,stat)
ch=size(sig1,1);
z1=size(sig1,3);
z2=size(sig2,3);
for i=1:ch
x1=squeeze(sig1(i,:,:));
x2=squeeze(sig2(i,:,:));
[~,~,~,stats]= ttest2(x1,x2,'Dim',2);
tst(:,i)=stats.tstat;
x3=cat(2,x1,x2);
parfor s=1:stat.surrn
gp1=randperm(z1+z2,z1);
gp2=setdiff(1:z1+z2,gp1);
[~,~,~,stats]= ttest2(x3(:,gp1),x3(:,gp2),'Dim',2);
tmp(:,s)=stats.tstat;
end
[R{i}, z{i}]=ERP_sig(tst(:,i),tmp,stat);
end
end
function [R, z]=ERP_sig(input,surr,stat)

critzp=quantile(surr,1-stat.voxel_pval,2);
critzn=quantile(surr,stat.voxel_pval,2);


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
    
    surrclusz=[surrclusz; Nmax;Pmax];
    
    
end

surrclusz=sort(surrclusz,'ascend');


z=input;
nonsigp=[];
R.corrz=zeros(size(z));

CCP= bwconncomp(bsxfun(@times,z,z>critzp));
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
    %     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=1-(dsearchn(surrclusz,clust_infoP')./length(surrclusz));
    Psigc=Psigp<stat.cluster_pval/2;
    Pidx=vertcat(CCP.PixelIdxList(Psigc));
    nonsigp=cat(1,nonsigp,Psigp(~Psigc));
    Psigp=Psigp(Psigc);
    Pz=clust_infoP(Psigc);
else
    Psigp=[];
    Pidx={};
    Pz=[];
end
CCN= bwconncomp(bsxfun(@times,z,(z<critzn)));
if CCN.NumObjects~=0
    clust_infoN =cellfun(@(x) sum(z(x)), CCN.PixelIdxList);
    %     Nsigp=normcdf(clust_infoN,msurr,stdsurr);
    Nsigp=dsearchn(surrclusz,clust_infoN')./length(surrclusz);
    Nsigc=Nsigp<stat.cluster_pval/2;
    nonsigp=cat(1,nonsigp,Nsigp(~Nsigc));
    
    Nidx=vertcat(CCN.PixelIdxList(Nsigc));
    Nz=clust_infoN(Nsigc);
    Nsigp=Nsigp(Nsigc);
else
    Nsigp=[];
    Nidx={};
    Nz=[];
    
end
R.sigz=[Pz Nz];
R.sigp=[Psigp; Nsigp];
idx=vertcat(Pidx{:},Nidx{:});
R.corrz(idx)=z(idx);
R.nonsigp=nonsigp;



end


