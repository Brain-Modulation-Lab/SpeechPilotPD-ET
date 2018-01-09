stat.voxel_pval=0.05; stat.cluster_pval=0.01; stat.surrn=1000;

Output=[];
for i=1:length(Results)
    tic
    for c=1:length(Cond)
            Output(i).(Cond{c}).(freq{f}).time=-Results(i).(Cond{c}).parameters{2}:1/1200:Results(i).(Cond{c}).parameters{4};
            ch=Results(i).(Cond{c}).parameters{12};
            nt=Results(i).(Cond{c}).parameters{8};
        for f=1:length(freq)
            
            
            for c2=1:ch
            z=Results(i).(Cond{c}).(freq{f}).z_Amp(:,c2:ch:end)' ;   
            
            t=mean(z)./(std(z)/sqrt(nt));
            t_su=zeros(length(t),stat.surrn);
            parfor s=1:stat.surrn
            z_su=z;
            rind = logical((randi([0,1],nt,1)));
            z_su(rind,:)=-z(rind,:);           
            t_su(:,s)=mean(z_su)./(std(z_su)/sqrt(nt));
            end
            [Output(i).(Cond{c}).(freq{f}).idx{c2},Output(i).(Cond{c}).(freq{f}).pval{c2}]=C1Dsigt(t,t_su,nt-1,stat);
            Output(i).(Cond{c}).(freq{f}).t_stat=t;    
            end          
                       
        end
    end
    toc
    
end

save('Power_permutation_results.mat','Output','-v7.3')