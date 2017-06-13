function [Reg,R,zg,surr]=calc_robreg(tr,base,pred,stat)
ch=length(tr);
stat.bscorr=0;
dx=size(tr{1},1);    dy=size(tr{1},2);   dz=size(tr{1},3); 
tr=cellfun(@abs, tr,'UniformOutput',false);
base=cellfun(@abs, base,'UniformOutput',false);
z=cellfun(@(x,y) bsxfun(@minus,x,mean(y,2)),tr,base,'UniformOutput', false);
X=bsxfun(@rdivide,pred,max(abs(pred)));
[nx, ny]=meshgrid(1:dx,1:dy);
b=zeros(dx,dy,size(X,2)+1);
for c=setdiff(1:ch,4)
ydat=z{c};
parfor i=1:numel(nx)
[tb(i,:), stats] = robustfit(X,squeeze(ydat(nx(i),ny(i),:)),'ols');
tp(i,:)=stats.p;
end

for i=1:numel(nx)
b(nx(i),ny(i),:)=tb(i,:);
p(nx(i),ny(i),:)=tp(i,:);
end
parfor s=1:stat.surrn
[bs(:,:,:,s)]=chimichanga(X,ydat,nx,ny,dz);
end
surr{c}=bs;
for p1=2:size(b,3)
[R{c,p1}, zg{c,p1}]=cluster_sig(b(:,:,p1),squeeze(bs(:,:,p1,:)),stat);
end
Reg(c).b=b;
Reg(c).p=p;
end
end

function [bs]=chimichanga(X,ydat,nx,ny,dz)
for i=1:numel(nx)
[tbs(i,:)] = robustfit(X(randperm(dz),:),squeeze(ydat(nx(i),ny(i),:)),'ols');
end
for i=1:numel(nx)
bs(nx(i),ny(i),:)=tbs(i,:);
end
end





