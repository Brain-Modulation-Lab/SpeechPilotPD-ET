function [R, z]=cluster_sigt(input,df,surr,stat,conn)
% msurr=mean(surr,3);
% stdsurr=std(surr,0,3);
critzp=quantile(surr,1-stat.voxel_pval,3);
critzn=quantile(surr,stat.voxel_pval,3);
% 
critz=abs(icdf('T',stat.voxel_pval,df));
critzp=critz*ones(size(input));
critzn=-critz*ones(size(input));
% 

surrclusz=zeros(size(surr,3),1);

        for s=1:size(surr,3)
            surrz=surr(:,:,s);
            Psurrclus=bwconncomp(bsxfun(@times,surrz,surrz>critzp),conn);
            if Psurrclus.NumObjects~=0
                Parea=cellfun(@(x) sum(surrz(x)),Psurrclus.PixelIdxList);
                Pmax=max(Parea);
            else Pmax=0;
            end
            Nsurrclus=bwconncomp(bsxfun(@times,surrz,surrz<critzn),conn);
            if Nsurrclus.NumObjects~=0
                Narea=(cellfun(@(x) sum(-surrz(x)),Nsurrclus.PixelIdxList));
                Nmax=max(Narea);
            else Nmax=0;
            end
            surrclusz(s,:)=max([Nmax Pmax]);
        end
surrclusz=sort(surrclusz(:),'ascend');


z=input;
nonsigp=[];
R.corrz=zeros(size(z));
CCP= bwconncomp(bsxfun(@times,z,z>=critzp),conn);
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
    %     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=(1-(dsearchn(surrclusz,clust_infoP')./length(surrclusz)));
    Psigc=Psigp<stat.cluster_pval;
    Pidx=vertcat(CCP.PixelIdxList(Psigc));
    nonsigp=cat(1,nonsigp,Psigp(~Psigc));
    Psigp=Psigp(Psigc);
    Pz=clust_infoP(Psigc);
else
    Psigp=[];
    Pidx={};
    Pz=[];
end
CCN= bwconncomp(bsxfun(@times,z,(z<=critzn)));
if CCN.NumObjects~=0
    clust_infoN =cellfun(@(x) -sum(z(x)), CCN.PixelIdxList);
    %     Nsigp=normcdf(clust_infoN,msurr,stdsurr);
    Nsigp=1-(dsearchn(surrclusz,clust_infoN')./length(surrclusz));
    Nsigc=Nsigp<stat.cluster_pval;
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
R.idx=[Pidx Nidx];
    