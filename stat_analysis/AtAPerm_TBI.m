function [Results]=AtAPerm_TBI(Vertices, Atlas, adj_1,adj_2,spacing)

for l=1:2
loc(l) = find_neighbor({Vertices(Atlas(7).Scouts(l).Vertices,:) },[spacing]);

end  
% parpool(8)    
    

labels={'LC','RC'};
% [x, y]= meshgrid(2:-1:1, 2:-1:1);
% iter=[nonzeros(reshape(triu(x)',1,[])) nonzeros(reshape(triu(y)',1,[]))];
iter=[1 ;2];
AT=[2];
for i=1:length(iter)
% Results(i).comb=[ labels(iter(i,1)) '-' labels(iter(i,2))];
NE(1,1)=loc(1,iter(i,1));
% NE{2}=loc{1,iter(i,2)};
%  A=adj_1(  Atlas(7).Scouts(iter(i,1)).Vertices, Atlas(7).Scouts(iter(i,2)).Vertices,:);
%  B=adj_2(  Atlas(7).Scouts(iter(i,1)).Vertices, Atlas(7).Scouts(iter(i,2)).Vertices,:);
 A=adj_1(  Atlas(7).Scouts(iter(i,1)).Vertices,:);
 B=adj_2(  Atlas(7).Scouts(iter(i,1)).Vertices,:);
for t=1:length(AT)
Results(i).clusters(t)=permtestND(A,B,[],[],AT(t),0.95,1000,0,NE);
end

end     

end 