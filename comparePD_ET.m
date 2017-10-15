%compareET_PD

ET = load('ET_populationAvgs.mat');
PD = load('PD_populationAvgs.mat');
gammaThresh = 3;
align = {'Cue', 'Onset'};
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
rows = ceil(length(freq)/2);

for aa = 1:length(align)
    figure;
    
    for ff = 1:length(freq) %frequency bands/plots
        subplot(rows, 2, ff);
        ETsel = ET.PopResults.(align{aa}).gammaMax >= gammaThresh;
        ETmean = nanmean(ET.PopResults.(align{aa}).popZ(:,ETsel,ff), 2);
        PDsel = PD.PopResults.(align{aa}).gammaMax >= gammaThresh;
        PDmean = nanmean(PD.PopResults.(align{aa}).popZ(:,PDsel,ff), 2);
        t = ET.PopResults.(align{aa}).time;
        plot(ET.PopResults.(align{aa}).time, ETmean, 'b', 'LineWidth', 2);
        hold on;
        plot(PD.PopResults.(align{aa}).time, PDmean, 'r', 'LineWidth', 2);
        
        title(freq{ff});
        set(gca, 'Ylim', [-5 5]);
        plot([t(1) t(end)], [3 3], '--k', 'LineWidth', 1); %3 SD lines
        plot([t(1) t(end)], [-3 -3], '--k', 'LineWidth', 1);
        PDeventPlotx = mean(PD.PopResults.(align{aa}).chEventTimes);
        PDeventPlotx = repmat(PDeventPlotx, 2,1)
        ETeventPlotx = mean(ET.PopResults.(align{aa}).chEventTimes);
        ETeventPlotx = repmat(ETeventPlotx, 2,1)
        plot(ETeventPlotx, [-5 -5 -5; 5 5 5], 'b', 'LineWidth',1);
        plot(PDeventPlotx, [-5 -5 -5; 5 5 5], 'r', 'LineWidth',1);
        if strcmp(align{aa},'Onset')
            set(gca,'Xlim', [-1.5 .7]);
        else
            set(gca, 'Xlim', [-.5 1.7]);
        end
    end
    axes(gcf, 'Position', [0, .9, .8, .1], 'Visible', 'off', 'Fontsize', 20);
    text(.5, .7, ['Alignment: ' align{aa}]);
end

