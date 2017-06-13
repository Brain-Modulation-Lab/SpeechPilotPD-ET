function [Results]=permute_cond(Cond1,Cond2,field,ROI,f,fq,t,time,stat)
% fq=fqb;
% t=[401 801];
% f=[3 21];
% time=-1.5:(1/400):1.5;

time=time(t(1):t(2));
surr=[];

figure
for r=1:3
    A=[];
    B=[];
    for i=1:length(Cond1)
        if ~isnan(Cond1(i).([ ROI{r} field])(1))
%                A=cat(3,A,mean(Cond1(i).([ ROI{r} field]),3));
%                B=cat(3,B,mean(Cond2(i).([ ROI{r} field]),3));  
        if size(Cond1(i).([ ROI{r} field]),3)<3
%             A=cat(3,A,mean(Cond1(i).([ ROI{r} field]),3));
%             B=cat(3,B,mean(Cond2(i).([ ROI{r} field]),3));            
        else
            x=Cond1(i).([ ROI{r} field]);
            x2=[];
            for i2=1:size(x,1)
                [coeff,score] = pca(squeeze(x(i2,:,:)),'VariableWeights','Variance');
                x2(i2,:) = score(:,1);
            end
            A=cat(3,A,x2);
            
            x=Cond2(i).([ ROI{r} field]);
            x2=[];
              for i2=1:size(x,1)
                [coeff,score] = pca(squeeze(x(i2,:,:)),'VariableWeights','Variance');
                x2(i2,:) = score(:,1);
            end
                            B=cat(3,B,x2);

                  
        end
        end
    end
    An=size(A,3);
  
    [~,~,~,st] = ttest(A(f(1):f(2),t(1):t(2),:),B(f(1):f(2),t(1):t(2),:),'Dim',3);
    parfor s=1:stat.surrn
        gp1=logical(mod(randi(An,[1 An]),2));
        gp2=~gp1;
        [~,~,~,stats] = ttest(cat(3,A(f(1):f(2),t(1):t(2),gp1),B(f(1):f(2),t(1):t(2),gp2)),cat(3,A(f(1):f(2),t(1):t(2),gp2),B(f(1):f(2),t(1):t(2),gp1)),'Dim',3);
        surr(:,:,s)=stats.tstat;
    end
    [R, z]=cluster_sig2(st.tstat,st.df(1),surr,stat,2,4);
    R.sigp
    Results(r).corr=R;
    Results(r).z=z;
    subplot(2,3,r)
    imagesc(time,fq(f(1):f(2)),R.corrz)
    colormap jet; set(gca,'Ydir','normal','Clim',[-2.5 2.5]);
    subplot(2,3,r+3)
    imagesc(time,fq(f(1):f(2)),z)
    colormap jet; set(gca,'Ydir','normal','Clim',[-2.5 2.5]);
    title(ROI{r})
end