sigclu=[];
clup=[];
surrn=100;
R=[];
results=[];
h=1;
load('D:\Dropbox\ERC\Kinematics.mat');
for i=1:length(subject)
   nidx(i)=find(~cellfun(@isempty,strfind(msubject,subject{i})));   
end
movement=movement(nidx,:);
tq=dsearchn(time',[-1.5;1.5]);
E=jk(:,:,:,tq(1):tq(2));
ntime=time(tq(1):tq(2));
for p1=1:size(movement,2)
    tic
pred=movement(:,p1);
sn=length(pred);
for i1=1:3
    for i2=1:3       
        
        [rho(:,i1,i2), pval] = corr(squeeze(E(i1,i2,:,:)),pred);
    
        [rhos pvals]=arrayfun(@(x) corr(squeeze(E(i1,i2,:,:)),pred(randperm(sn))),1:surrn,'UniformOutput',0);
        
      
        sclu=cellfun(@(x) bwconncomp(x<0.05),pvals,'UniformOutput',0);
        sclsize=zeros(surrn,1);
        tmp=cellfun(@(x) max(cell2mat(cellfun(@numel ,x.PixelIdxList,'UniformOutput',0))),sclu,'UniformOutput',0);
        sclsize(~cellfun(@isempty,tmp))=cell2mat(tmp);
        sclsize=sort(sclsize,'ascend');
        dclu=bwconncomp(pval<0.05);
        dclusiz=cellfun(@numel,dclu.PixelIdxList);
        idx=dclusiz>=quantile(sclsize,0.95);
        if sum(idx)>0
            idx=find(idx);
            for gh=1:length(idx)
                sc=dclu.PixelIdxList(idx(gh));
                results{h,1}=vars(p1);
                results{h,2}=i1;
                results{h,3}=i2;
                results{h,5}=ntime(sc{:});  
                results{h,4}=mean(squeeze(rho(sc{:},i1,i2))); 
                
                if isempty(find(sclsize>dclusiz(idx(gh)),1,'first')/surrn);
                    results{h,6}=0;
                else
                    results{h,6}=((surrn*0.05)-(find(sclsize(1+surrn*0.95:end)>dclusiz(idx(gh)),1,'first')))/surrn;
                end
                h=h+1;
            end
        end
        clearvars rho rhos pval pvals
    end   
end
toc
sigclu=[];
clup=[];
end
%%
save(['beta_command' '_corr.mat'],'results')
