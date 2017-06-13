function [final,maxT,surr]=permtest2D(A,B,thresh,alpha,surrn,test)
% Input
% A: M x N x O matrix  B is the same size
% thresh is the threshold for the images
% alpha : alpha level for significance 0.95 is 95%
% test is 'ttest' for 2 way ttest and 'nonparam' for ranksum 
% surrn is the number of surrogate runs


Spool=cat(3,A,B);
nA=size(A,3); nB=size(B,3);
ntot=nA+nB;
surr=zeros(size(A,1),size(A,2),surrn);
maxT=zeros(surrn,1);
switch test
    case 'ttest'
        parfor s=1:surrn
            As=Spool(:,:,randperm(ntot,nA));
            Bs=Spool(:,:,randperm(ntot,nB));
            [~,~,~,stats] = ttest2(As,Bs,'Dim',3);
            CCp=bwconncomp(stats.tstat>=thresh);
            if CCp.NumObjects~=0
                pclu=cell2mat(cellfun(@(x) sum(stats.tstat(x)),CCp.PixelIdxList,'UniformOutput',false));
            else
                pclu=0;
            end
            CCn=bwconncomp(stats.tstat<=-thresh);
            if CCn.NumObjects~=0
                nclu=cell2mat(cellfun(@(x) sum(stats.tstat(x)),CCn.PixelIdxList,'UniformOutput',false));
            else
                nclu=0;
            end
            surr(:,:,s)=stats.tstat;
            maxT(s,1)=max(abs([pclu nclu]));
        end
        [~,~,~,stats] = ttest2(A,B,'Dim',3);
        stats=stats.tstat;
    case 'nonparam'
    
           parfor s=1:surrn
            As=cellfun(@squeeze,num2cell(Spool(:,:,randperm(ntot,nA)),3),'UniformOutput',false);
            Bs=cellfun(@squeeze,num2cell(Spool(:,:,randperm(ntot,nB)),3),'UniformOutput',false);
            [~,~,r]=cellfun(@(x,y) ranksum(x,y),As,Bs,'UniformOutput',false);
            zstat=cell2mat(cellfun(@(x) x.zval,r,'UniformOutput',false));
            CCp=bwconncomp(zstat>=thresh);
            if CCp.NumObjects~=0
                pclu=cell2mat(cellfun(@(x) sum(zstat(x)),CCp.PixelIdxList,'UniformOutput',false));
            else
                pclu=0;
            end
            CCn=bwconncomp(zstat<=-thresh);
            if CCn.NumObjects~=0
                nclu=cell2mat(cellfun(@(x) sum(zstat(x)),CCn.PixelIdxList,'UniformOutput',false));
            else
                nclu=0;
            end
            maxT(s,1)=max(abs([pclu nclu]));
            surr(:,:,s)=zstat;

           end
          
            As=cellfun(@squeeze,num2cell(A,3),'UniformOutput',false);
            Bs=cellfun(@squeeze,num2cell(B,3),'UniformOutput',false);
            [~,~,r]=cellfun(@(x,y) ranksum(x,y),As,Bs,'UniformOutput',false);
            stats=cell2mat(cellfun(@(x) x.zval,r,'UniformOutput',false));
end

maxT=sort(maxT);
sigT=maxT(alpha*length(maxT));
final=zeros(size(stats));
datap=bwconncomp(stats>=thresh);
if datap.NumObjects~=0
    dataclup=cell2mat(cellfun(@(x) sum(stats(x)),datap.PixelIdxList,'UniformOutput',false));
    datap.PixelIdxList=datap.PixelIdxList(dataclup>=sigT);
    final(vertcat(datap.PixelIdxList{:}))=stats(vertcat(datap.PixelIdxList{:}));
end
datan=bwconncomp(stats<=-thresh);
if datan.NumObjects~=0
    dataclun=cell2mat(cellfun(@(x) sum(stats(x)),datan.PixelIdxList,'UniformOutput',false));
    datan.PixelIdxList=datan.PixelIdxList(abs(dataclun)>=sigT);
    final(vertcat(datan.PixelIdxList{:}))=stats(vertcat(datan.PixelIdxList{:}));
end
end