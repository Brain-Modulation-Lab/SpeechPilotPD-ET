function  [idx,pval]=C1Dsig(p,ps)
p(isnan(p))=1;
ps(isnan(ps))=1;
surrn=size(ps,2);
sclsize=zeros(surrn,1);

sclu=arrayfun(@(x) bwconncomp(ps(:,x)<0.05),1:surrn,'UniformOutput',0);
tmp=cellfun(@(x) max(cell2mat(cellfun(@numel ,x.PixelIdxList,'UniformOutput',0))),sclu,'UniformOutput',0);
sclsize(~cellfun(@isempty,tmp))=cell2mat(tmp);
sclsize=sort(sclsize,'ascend');
dclu=bwconncomp(p<0.05);
if dclu.NumObjects~=0
dclusiz=cellfun(@numel,dclu.PixelIdxList);
pval=1-dsearchn(sclsize,dclusiz')./surrn;
idx=dclu.PixelIdxList(pval<0.05);
pval=pval(pval<0.05);
else
 idx=[];
pval=[];
end
    

end