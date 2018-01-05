%compareET_PD

ET = load('ET_population_locations.mat');
%PD = load('PD_populationAvgs.mat');
locNum = 1;
gammaThresh = 5;
align = {'Cue', 'Onset'};
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
c = {[0 0 0], [0 0 1], [0 1 0]};
cerr = {[.5 .5 .5], [.5 .5 1], [.5 1 .5]};
rows = length(freq);
figure;
for ll = 1:length(ET.PopResults.loc)
for aa = 1:length(align)
    for ff = 1:length(freq) %frequency bands/plots
        subplot(rows, 2, 2*(ff-1)+aa);
        ETsel = ET.PopResults.loc(ll).(align{aa}).gammaMax >= gammaThresh;
        nET = sum(ETsel(:));
        ETmean = nanmean(ET.PopResults.loc(ll).(align{aa}).popZ(:,ETsel,ff), 2);
        ETsem = nanstd(ET.PopResults.loc(ll).(align{aa}).popZ(:,ETsel,ff),0, 2)./sqrt(nET);
        t = ET.PopResults.loc(ll).(align{aa}).time;
        plot_err_poly(gca, ET.PopResults.loc(ll).(align{aa}).time, ETmean, ETsem, c{ll}, cerr{ll},1);
        hold on;
        
        title(freq{ff});
        set(gca, 'Ylim', [-7 10], 'TickDir', 'out');
        plot([t(1) t(end)], [3 3], '--k', 'LineWidth', 1); %3 SD lines
        plot([t(1) t(end)], [-3 -3], '--k', 'LineWidth', 1);
        ETeventPlotx = mean(ET.PopResults.loc(ll).(align{aa}).chEventTimes);
        ETeventPlotx = repmat(ETeventPlotx, 2,1);
        plot(ETeventPlotx, [-5 -5 -5; 5 5 5], 'k', 'LineWidth',1);
        if strcmp(align{aa},'Onset')
            set(gca,'Xlim', [-1.5 .5]);
        else
            set(gca, 'Xlim', [-.2 1]);
        end
    end
    
    axes('Parent', gcf, 'Position', [0, .9, .8, .1], 'Visible', 'off', 'Fontsize', 20);
    text(.5, .7, ['Alignment: ' align{aa}]);
end
end
