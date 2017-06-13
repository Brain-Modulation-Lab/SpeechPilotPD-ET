function [R, z]=cluster_sig(input,surr,stat,side,conn)
msurr=mean(surr,3);
stdsurr=std(surr,0,3);
surr=bsxfun(@rdivide,bsxfun(@minus,surr,msurr),stdsurr);
critzp=quantile(surr,1-stat.voxel_pval,3);
critzn=quantile(surr,stat.voxel_pval,3);
% critzp=norminv(1-stat.voxel_pval,mean(surr(:)),std(surr(:)))*ones(size(input));
% critzn=norminv(stat.voxel_pval,mean(surr(:)),std(surr(:)))*ones(size(input));
surrclusz=zeros(size(surr,3),2);
switch side
    case 2
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
                Narea=(cellfun(@(x) sum(surrz(x)),Nsurrclus.PixelIdxList));
                Nmax=min(Narea);
            else Nmax=0;
            end
            
            surrclusz(s,:)=[Pmax Nmax];
            
            
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
            surrclusz(s,1)=max(Pmax);
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
            surrclusz(s,1)=(Nmax);
        end
end
surrclusz=sort(abs(surrclusz),'ascend');


z=bsxfun(@rdivide,bsxfun(@minus,input,msurr),stdsurr);
nonsigp=[];
R.corrz=zeros(size(z));
switch side 
    case 2
CCP= bwconncomp(bsxfun(@times,z,z>critzp),conn);
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
    %     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=(1-(dsearchn(surrclusz(:,1),clust_infoP')./length(surrclusz)))*2;
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
CCN= bwconncomp(bsxfun(@times,z,(z<critzn)));
if CCN.NumObjects~=0
    clust_infoN =cellfun(@(x) -sum(z(x)), CCN.PixelIdxList);
    %     Nsigp=normcdf(clust_infoN,msurr,stdsurr);
    Nsigp=(1-(dsearchn(surrclusz(:,2),clust_infoN')./length(surrclusz)))*2;
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
    case 1
CCP= bwconncomp(bsxfun(@times,z,z>critzp),conn);
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(z(x)), CCP.PixelIdxList);
%     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=1-(dsearchn(surrclusz(:,1),clust_infoP')./stat.surrn);

    Psigc=find(Psigp<stat.cluster_pval);
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
    Nsigp=dsearchn(surrclusz(:,2),clust_infoN')./stat.surrn;

    Nsigc=find(Nsigp<stat.cluster_pval);
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