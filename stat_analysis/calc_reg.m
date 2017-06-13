function [StatR,bz]=calc_reg(tr,base,pred,stat)
ch=length(tr);
stat.bscorr=0;
dx=size(tr{1},1);    dy=size(tr{1},2);   dz=size(tr{1},3); 
tr=cellfun(@abs, tr,'UniformOutput',false);
base=cellfun(@abs, base,'UniformOutput',false);
z=cellfun(@(x,y) bsxfun(@rdivide,bsxfun(@minus,x,mean(y,2)),std(y,0,2)),tr,base,'UniformOutput', false);
pred=zscore(pred,0,1)';
critz=norminv(1-stat.voxel_pval);
b=zeros(dx,dy,size(pred,1));
for c=setdiff(1:ch,4)
ydat=reshape(z{c},[],dz);
b =reshape( (pred*pred')\pred*ydat',size(pred,1),dx,dy);
for s=1:stat.surrn
    rpred=pred(:,randperm(dz));
bs(:,:,:,s) =reshape( (rpred*rpred')\rpred*ydat',size(pred,1),dx,dy);
end
for p=1:size(pred,1)
[StatR{c,p}, bz{c,p}]=cluster_sig(squeeze(b(p,:,:)),squeeze(bs(p,:,:,:)),stat);
    
end

end
end

