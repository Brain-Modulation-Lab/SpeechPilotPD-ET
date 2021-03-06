%compareET_PD

ET = load('ET_populationAvgs.mat');
PD = load('PD_populationAvgs.mat');
gammaThresh = 5;
align = {'Cue', 'Onset'};
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
rows = length(freq);
figure;
for aa = 1:length(align)
    for ff = 1:length(freq) %frequency bands/plots
        subplot(rows, 2, 2*(ff-1)+aa);
        ETsel = ET.PopResults.(align{aa}).gammaMax >= gammaThresh;
        nET = sum(ETsel(:));
        ETmean = nanmean(ET.PopResults.(align{aa}).popZ(:,ETsel,ff), 2);
        ETsem = nanstd(ET.PopResults.(align{aa}).popZ(:,ETsel,ff),0, 2)./sqrt(nET);
        PDsel = PD.PopResults.(align{aa}).gammaMax >= gammaThresh;
        nPD = sum(PDsel(:));
        PDmean = nanmean(PD.PopResults.(align{aa}).popZ(:,PDsel,ff), 2);
        PDsem = nanstd(PD.PopResults.(align{aa}).popZ(:,PDsel,ff),0, 2)./sqrt(nPD);
        t = ET.PopResults.(align{aa}).time;
        plot_err_poly(gca, ET.PopResults.(align{aa}).time, ETmean, ETsem, [0 0 1], [.5 .5 1],1);
        hold on;
        plot_err_poly(gca, PD.PopResults.(align{aa}).time, PDmean, PDsem, [1 0 0], [1 .5 .5],1);
        
        %plot(ET.PopResults.(align{aa}).time, ETmean, 'b', 'LineWidth', 2);
        %hold on;
        %plot(ET.PopResults.(align{aa}).time, ETmean-ETsem, 'b--', 'LineWidth', 1);
        %plot(ET.PopResults.(align{aa}).time, ETmean+ETsem, 'b--', 'LineWidth', 1);
        %plot(PD.PopResults.(align{aa}).time, PDmean-PDsem, '--r', 'LineWidth', 1);
        %plot(PD.PopResults.(align{aa}).time, PDmean+PDsem, '--r', 'LineWidth', 1);
        %plot(PD.PopResults.(align{aa}).time, PDmean, 'r', 'LineWidth', 2);
        title(freq{ff});
        set(gca, 'Ylim', [-5 5], 'TickDir', 'out');
        plot([t(1) t(end)], [3 3], '--k', 'LineWidth', 1); %3 SD lines
        plot([t(1) t(end)], [-3 -3], '--k', 'LineWidth', 1);
        PDeventPlotx = mean(PD.PopResults.(align{aa}).chEventTimes);
        PDeventPlotx = repmat(PDeventPlotx, 2,1)
        ETeventPlotx = mean(ET.PopResults.(align{aa}).chEventTimes);
        ETeventPlotx = repmat(ETeventPlotx, 2,1)
        plot(ETeventPlotx, [-5 -5 -5; 5 5 5], 'b', 'LineWidth',1);
        plot(PDeventPlotx, [-5 -5 -5; 5 5 5], 'r', 'LineWidth',1);
        if strcmp(align{aa},'Onset')
            set(gca,'Xlim', [-1.5 .5]);
        else
            set(gca, 'Xlim', [-.2 1]);
        end
    end
    
    axes('Parent', gcf, 'Position', [0, .9, .8, .1], 'Visible', 'off', 'Fontsize', 20);
    text(.5, .7, ['Alignment: ' align{aa}]);
end

