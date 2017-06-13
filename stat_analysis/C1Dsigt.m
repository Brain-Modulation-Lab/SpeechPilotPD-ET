function  [idx,pval]=C1Dsigt(input,surr,df,stat)
critt=abs(icdf('T',stat.voxel_pval,df));
surrclusz=zeros(stat.surrn,1);
for s=1:size(surr,2)
    surrz=surr(:,s);
    
    Psurrclus=bwconncomp(bsxfun(@times,surrz,surrz>=critt));
    if Psurrclus.NumObjects~=0
        Parea=cellfun(@(x) sum(surrz(x)),Psurrclus.PixelIdxList);
        Pmax=max(Parea);
    else Pmax=0;
    end
  
      Nsurrclus=bwconncomp(bsxfun(@times,surrz,surrz<=-critt));
    if Nsurrclus.NumObjects~=0
        Narea=cellfun(@(x) -sum(surrz(x)),Nsurrclus.PixelIdxList);
        Nmax=max(Narea);
    else Nmax=0;
    end
  
    surrclusz(s)=max([Pmax Nmax]);
    
    
    
    
end
surrclusz=sort(surrclusz,'ascend');



CCP= bwconncomp(bsxfun(@times,input,input>=critt));
if CCP.NumObjects~=0
    clust_infoP =cellfun(@(x) sum(input(x)), CCP.PixelIdxList);
    %     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Psigp=(1-(dsearchn(surrclusz,clust_infoP')./length(surrclusz)));
    Psigc=Psigp<0.05;
    Pidx=vertcat(CCP.PixelIdxList(Psigc));
    Psigp=Psigp(Psigc);
else
    Psigp=[];
    Pidx={};
 
end


CCN= bwconncomp(bsxfun(@times,input,input<=-critt));
if CCN.NumObjects~=0
    clust_infoN =cellfun(@(x) -sum(input(x)), CCN.PixelIdxList);
    %     Psigp=1-normcdf(clust_infoP,msurr,stdsurr);
    Nsigp=(1-(dsearchn(surrclusz,clust_infoN')./length(surrclusz)));
    Nsigc=Nsigp<0.05;
    Nidx=vertcat(CCN.PixelIdxList(Nsigc));
    Nsigp=Nsigp(Nsigc);
else
    Nsigp=[];
    Nidx={};
 
end



pval=[Psigp; Nsigp];
idx=[Pidx Nidx];

 
        
end