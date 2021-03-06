h=1;
Cond={'Cue','Onset'};
freq={'delta','theta','alpha','beta1','beta2','Gamma','Hgamma'};
stat.voxel_pval=0.05; stat.cluster_pval=0.05; stat.surrn=1000;
Master_results=[];

for i=1:length(Results)
    
    ch=Results(i).(Cond{1}).parameters{12};
    nt=Results(i).(Cond{1}).parameters{8};
    xloc=strfind(Results(i).Session,'_');
    figure
    Master_results(h).Subject=Results(i).Session(1:xloc(1)-1);
    Master_results(h).WordList=Results(i).Session(xloc(1)+1:xloc(1)+8);
%     depth=Session_depth{strcmp(Session_depth(:,1),Results(i).Session(1:end-7)),2}+3;
%     Top=STN_borders([2 4 6],strcmp(STN_borders(1,1:end),Master_results(h).Subject));
%     Bottom=STN_borders([3 5 7],strcmp(STN_borders(1,1:end),Master_results(h).Subject));
%     Top(cellfun(@isempty,Top))={NaN};
%     Bottom(cellfun(@isempty,Bottom))={NaN};
    
%     UnitDis=cellfun(@(x,y) (x-y)/100,Top,Bottom,'UniformOutput',0);
%     NormDepth=cellfun(@(x,y) 100-((x-depth)/y),Top,UnitDis,'UniformOutput',0);
    
    ch=Results(i).(Cond{1}).parameters{12};
    nt=Results(i).(Cond{1}).parameters{8};
    for c2=1:ch
        
         Master_results(h).Subject=Results(i).Session(1:xloc(1)-1);
%     Master_results(h).WordList=Results(i).Session(xloc(1)+1:xloc(2)-1);
                 Master_results(h).Channel=c2;
%                 Master_results(h).NormDepth=NormDepth{c2};
        for c=1:length(Cond)
            time=(-Results(i).(Cond{c}).parameters{2}:1/1200:Results(i).(Cond{c}).parameters{4})';
            
            switch Cond{c}
                case 'Cue'
                    tstart=601;
                case 'Onset'
                    tstart=dsearchn(time,-0.5);
            end
            time=time(tstart:end);
            
            
            for f=1:length(freq)
                
                z=Results(i).(Cond{c}).(freq{f}).z_Amp(tstart:end,c2:ch:end)' ;
                z=(cell2mat(arrayfun(@(x) smooth(z(x,:),75),1:size(z,1),'Uni',0)))';
                t=mean(z)./(std(z)/sqrt(nt));
                t_su=zeros(length(t),stat.surrn);
                parfor s=1:stat.surrn
                    z_su=z;
                    rind = logical((randi([0,1],nt,1)));
                    z_su(rind,:)=-z(rind,:);
                    t_su(:,s)=mean(z_su)./(std(z_su)/sqrt(nt));
                end
                [idx,pval]=C1Dsigt(t,t_su,nt-1,stat);
                if ~isempty(pval)
                    
                    Master_results(h).([freq{f} '_' Cond{c} '_zAMP_time'])=cellfun(@(x)[time(x(1)) time(x(end))],idx,'Uni',0);
                    Master_results(h).([freq{f} '_' Cond{c} '_zAMP'])=cellfun(@(x) mean(t(x))  ,idx,'Uni',0);
                    Master_results(h).([freq{f} '_' Cond{c}  '_zAmp_pvalue'])=pval;
                else
                    Master_results(h).([freq{f} '_' Cond{c} '_zAMP_time'])=[0 0];
                    Master_results(h).([freq{f} '_' Cond{c} '_zAMP'])=0;
                    Master_results(h).([freq{f} '_' Cond{c} '_zAmp_pvalue'])=1;
                end
                

                p=Results(i).(Cond{c}).(freq{f}).p_IPC(tstart:end,c2);
                IPC=Results(i).(Cond{c}).(freq{f}).IPC_tr(tstart:end,c2);
                pcor=fdr(downsample(p,6),0.05);
                %                                 pcor=0.05;
                if strcmp(Cond{c},'Cue') && strcmp(freq{f},'Gamma')
                    subplot(2,3,c2)
                    plot(time,IPC)
                    hold on
                    %                 line([min(time) max(time)],repmat(R(i).(Cond{c}).(freq{f}).pcrit(c2),2,1),'Color','r')
                    set(gca,'Xlim',[min(time) max(time)],'Ylim',[0 1])
                    
                    
                end
                if ~isempty(pcor)
                    CC=bwconncomp(p<pcor);
                    if strcmp(Cond{c},'Cue') && strcmp(freq{f},'Gamma')
                        
                        scatter(time(vertcat(CC.PixelIdxList{:})),0.2*ones(length(vertcat(CC.PixelIdxList{:})),1),'r','filled')
                        
                    end
                    Master_results(h).([freq{f} '_' Cond{c} '_IPC_time'])=cellfun(@(x)[time(x(1)) time(x(end))],CC.PixelIdxList,'Uni',0);
                    Master_results(h).([freq{f} '_' Cond{c} '_IPC'])=cellfun(@(x) max(IPC(x))  ,CC.PixelIdxList,'Uni',0);
                    Master_results(h).([freq{f} '_' Cond{c}  '_pvalue'])=pcor;
                else
                    Master_results(h).([freq{f} '_' Cond{c} '_IPC_time'])=[0 0];
                    Master_results(h).([freq{f} '_' Cond{c} '_IPC'])=0;
                    Master_results(h).([freq{f} '_' Cond{c} '_pvalue'])=1;
                end
            end
        end
        
        h=h+1
        
    end
end

