% Look at population timing, cue versus onset

groups = {'ET', 'PD'};
colors = {[0 0 1], [1 0 0]};
fh = figure;
for gg=1:length(groups)
    load( [savedDataDir, filesep, groups{gg} '_populationAvgs_Loc2.mat']); 
    for ll=1:length(PopResults.loc)
        ah = subplot(2,2,ll);
        hold on;
        plot(PopResults.loc(ll).Cue.gammaMax, PopResults.loc(ll).Onset.gammaMax, 'o','Color', colors{gg});
        title(PopResults.locations{ll});
        xlabel('Cue Aligned - Broadband Gamma Max (Z)', 'Fontsize', 14); 
        ylabel('Onset Aligned - Broadband Gamma Max (Z)', 'Fontsize', 14); 
        plot([0 20], [0 20], 'k--');
    end
end