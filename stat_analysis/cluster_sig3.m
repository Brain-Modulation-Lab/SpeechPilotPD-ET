function [R, z]=cluster_sig3(input,surr,stat,side,conn)
% msurr=mean(surr,3);
% stdsurr=std(surr,0,3);
critzp=quantile(surr,1-stat.voxel_pval,3);
critzn=quantile(surr,stat.voxel_pval,3);

surrclusz=[];
switch side
    case 2
        for s=1:size(surr,3)
            surrz=surr(:,:,s);
            Psurrclus=bwconncomp(bsxfun(@times,surrz,surrz>critzp),conn);
            if Psurrclus.NumObjects~=0
                Parea=cellfun(@(x) mean(surrz(x)),Psurrclus.PixelIdxList);
                Pmax=max(Parea);
            else Pmax=0;
            end
            Nsurrclus=bwconncomp(bsxfun(@times,surrz,surrz<critzn),conn);
            if Nsurrclus.NumObjects~=0
                Narea=(cellfun(@(x) mean(surrz(x)),Nsurrclus.PixelIdxList));
                Nmax=min(Narea);
            else Nmax=0;
            end
            surrclusz=[surrclusz; Nmax; Pmax];
        end
    case 1
        for s=1:size(surr,3)
            surrz=surr(:,:,s);
            Psurrclus=bwconncomp(bsxfun(@times,surrz,surrz>critzp),conn);
            if Psurrclus.NumObjects~=0
                Parea=cellfun(@(x) sum(surrz(x)),Psurrclus.PixelIdxList);
                Pmax=max(Parea);
            else Pmax=0;
            end
            surrclusz=[surrclusz; Pmax];
        end
    case -1
        for s=1:size(surr,3)
            surrz=surr(:,:,s);
            Nsurrclus=bwconncomp(bsxfun(@times,surrz,surrz<critzn),conn);
            if Nsurrclus.NumObjects~=0
                Narea=cellfun(@(x) sum(surrz(x)),Nsurrclus.PixelIdxList);
                Nmax=min(Narea);
            else Nmax=0;
            end
           surrclusz=[surrclusz; Nmax]
        end
end
surrclusz=sort(surrclusz,'ascend');

msurr=mean(surrclusz);
stdsurr=std(surrclusz);

z=input;
nonsigp=[];
R.corrz=zeros(size(z));
switch side 
    case 2
CCP= bwconncomp(bsxfun(@times,z,z>critzp),conn);
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) mean(z(x)), CCP.PixelIdxList);
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
    clust_infoN =cellfun(@(x) mean(z(x)), CCN.PixelIdxList);
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
    case 1
CCP= bwconncomp(bsxfun(@times,z,z>critzp),conn);
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
%     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=1-(dsearchn(surrclusz,clust_infoP')./length(surrclusz));

    Psigc=find(Psigp<stat.cluster_pval/2);
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
        
    case -1

CCN= bwconncomp(bsxfun(@times,z,(z<critzn)));
if CCN.NumObjects~=0
    clust_infoN =cellfun(@(x) sum(z(x)), CCN.PixelIdxList);
%     Nsigp=normcdf(clust_infoN,msurr,stdsurr);
    Nsigp=dsearchn(surrclusz,clust_infoN')./length(surrclusz);

    Nsigc=find(Nsigp<stat.cluster_pval/2);
    Nidx=vertcat(CCN.PixelIdxList(Nsigc));
    Nz=clust_infoN(Nsigc);
    Nsigp=Nsigp(Nsigc);
else
    Nsigp=[];
    Nidx={};
    Nz=[];
end
R.sigz=Nz;
R.sigp=Nsigp;
idx=vertcat(Nidx{:});
R.corrz(idx)=z(idx);      
        
        
end
