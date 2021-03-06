function [Results]=AtAPerm(GridLoc, GridAtlas, adj_R,adj_L)

for l=1:4
 switch l
case {1 2}
loc(l) = find_neighbor({GridLoc(GridAtlas.Scouts(l).GridRows,:) },[0.01]);
case {3 4}
loc(l) = find_neighbor({GridLoc(GridAtlas.Scouts(l).GridRows,:) },[0.002]);
end  
    
end

adj_R(:,:,[5])=[];
adj_L(:,:,[3 6  10 12 13])=[];
% 
% for s=1:length(GridAtlas.Scouts)
% id=GridAtlas.Scouts(s).GridRows;
% eudist=zeros(length(id),length(id));
% for i=1:length(id)
% eudist(i,:)=sqrt(sum(bsxfun(@minus, GridLoc(id(i),:), GridLoc(id,:)).^2,2));
% end
% eudist(1:length(id)+1:end)=1;
% 
% loc{s}=zeros(size(eudist));
% loc{s}(1:length(id)+1:end)=1;
% for i=1:length(id)
%  tmp=sort(eudist(i,:),'ascend');
% loc{s}(eudist(i,:)<=tmp(5),i)=1; 
% end
% end

labels={'LC','RC','LH','RH'};
[x, y]= meshgrid(4:-1:1, 4:-1:1);
iter=[nonzeros(reshape(triu(x)',1,[])) nonzeros(reshape(triu(y)',1,[]))];
AT=[1.64 1.96 2:0.25:3];
n=9000;adj_L=sqrt(adj_L);
adj_R=sqrt(adj_R);
iter=[2 4];
for i=1:size(iter,1)
Results(i).comb=[ labels(iter(i,1)) '-' labels(iter(i,2))];
NE(1,1)=loc(1,iter(i,1));
% NE(1,1)=loc(1,iter(i,2));
% 
% NE{2}=loc{1,iter(i,2)};
A=[];
for ia=1:size(adj_R,3)
   [~,score]= pca(adj_R(  GridAtlas.Scouts(iter(i,1)).GridRows, GridAtlas.Scouts(iter(i,2)).GridRows,ia));
    A=cat(2,A,score(:,1));
    
end

B=[];
for ib=1:size(adj_L,3)
   [~,score]= pca(adj_L(  GridAtlas.Scouts(iter(i,1)).GridRows, GridAtlas.Scouts(iter(i,2)).GridRows,ib));
   B=cat(2,B,score(:,1));
    
end
% 
% A=squeeze((adj_R(  GridAtlas.Scouts(iter(i,1)).GridRows, GridAtlas.Scouts(iter(i,2)).GridRows,:)));
% B=squeeze((adj_L(  GridAtlas.Scouts(iter(i,1)).GridRows, GridAtlas.Scouts(iter(i,2)).GridRows,:)));   
% 


for t=1:length(AT)
     try
Results(i).clusters(t)=permtestND(A,B,[],[],AT(t),0.975,100,0,NE);
    catch 
    end
end

end     

end                                                                