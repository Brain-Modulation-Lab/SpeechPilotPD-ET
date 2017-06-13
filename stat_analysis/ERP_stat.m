function [tr,base,R,z]=ERP_stat(signal, fs,Events, prestim, poststim, baseline, baseline_dur,ds,stat)
if size(signal,1)>size(signal,2)    
    signal=signal';
end
ch=size(signal,1);
n=round(length(signal)/ds);

Events=round(Events*fs/ds);
prestim=round(prestim*fs/ds);
poststim=round(poststim*fs/ds);
baseline=round(baseline*fs/ds);
baseline_dur=round(baseline_dur*fs/ds);
signal=squeeze(num2cell(downsample(signal',ds),[1]));
    bind=[];
for b=1:length(baseline)
    bind=cat(2,bind,baseline(b)-baseline_dur:baseline(b));    
end
tind=[];
for t=1:length(Events)
    tind=cat(2,tind,Events(t)-prestim:Events(t)+poststim);
end

dx=length(tind)/length(Events);   dz=length(Events);
tr=cellfun(@(x) reshape(x(tind,:)',dx,dz),signal,'UniformOutput', false);
dxb=length(bind)/length(baseline);   dzb=length(baseline);
base=cellfun(@(x) reshape(x(bind,:)',dxb,dzb),signal,'UniformOutput', false);

parfor s=1:stat.surrn
sind=[];
sevents=randperm(n-1-dx,dz);
sevents(sevents<=dx)=sevents(sevents<=dx)+dx;
for t=1:length(sevents)
    sind=cat(2,sind,round(sevents(t)-((dx-1)/2)):round(sevents(t)+((dx-1)/2)));
end

sr=cellfun(@(x) reshape(x(sind,:)',dx,dz),signal,'UniformOutput', false);
[~,~,~,stats]=arrayfun(@(x) ttest(bsxfun(@minus,sr{x}',mean(base{x},1)')),1:ch,'UniformOutput', false);
stats=vertcat(stats{:});
surrts(:,:,s)=vertcat(stats.tstat);


end
for i=1:ch
 x1=bsxfun(@minus,tr{i}',mean(base{i},1)');
 [~,~,~,stats]= ttest(x1);
 tst(:,i)=stats.tstat; 
 [R{i}, z{i}]=ERP_sig(tst(:,i),squeeze(surrts(i,:,:)),stat);
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



