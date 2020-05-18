%Plot the mean for each session/electrode for each frequency 
alignOnset = 1;

sd = summaryData;
for ff=1:length(sd.freq_labels)
  % Summary data across sessions
  [ah2, fh2] = subplot_pete(length(sd.loc_labels), 1, 'Electrode Number', 'Max/Min resp', sd.freq_labels{ff});
  set(fh2, 'Renderer', 'painters');
  % Timecourse figure w/ histogram 
  [ah, fh] = subplot_pete(length(sd.loc_labels), 2, 'Time from speech onset (sec)', 'Z-score resp', sd.freq_labels{ff});
  set(fh, 'Renderer', 'painters');
  nsites = length(sd.loc_labels);
  for ll=1:nsites 
    title(ah(ll), sd.loc_labels{ll});
    axes(ah(ll));
    pd_mean = nanmean(sd.PD.freq(ff).loc(ll).perSessionZ,2);
    et_mean = nanmean(sd.ET.freq(ff).loc(ll).perSessionZ,2);
    pd_n = size(sd.PD.freq(ff).loc(ll).perSessionZ,2);
    et_n = size(sd.ET.freq(ff).loc(ll).perSessionZ,2);
    t = sd.ET.freq(ff).loc(ll).time;
    pi = find(t>-1); pi = pi(1):10:pi(end);
    tpi = t(pi);
    t_wind = find(t>-.5 & t<2);
    
    et_max = max(sd.ET.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    et_min = min(sd.ET.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    
    %plot all of the responses by electrode/session as colormaps
    hold on;
    z = cat(2, sd.PD.freq(ff).loc(ll).perSessionZ(pi,:), NaN*zeros(length(pi),4), sd.ET.freq(ff).loc(ll).perSessionZ(pi,:));
    axes(ah(ll));
    imagesc(sd.ET.freq(ff).loc(ll).time(pi), 1:size(z,2), z');
    ylim(ah(ll), [1 size(z,2)]);
    xlim(ah(ll), [-1 t(end)]);
    colorbar;
    ah(ll).YDir='reverse';
    
    %p values
    testrange = sd.PD.freq(ff).loc(ll).clusterTt(1,:); %assuming the same range for all
    lengthp = size(sd.PD.freq(ff).loc(ll).clusterTh,1);
    ptime = linspace(testrange(1), testrange(2), lengthp);
    clusterTh = cat(2, sd.PD.freq(ff).loc(ll).clusterTh, zeros(lengthp,4), sd.ET.freq(ff).loc(ll).clusterTh);
    clusterTp = cat(2, sd.PD.freq(ff).loc(ll).clusterTp, NaN*zeros(lengthp,4), sd.ET.freq(ff).loc(ll).clusterTp);
    sigi = []; sigt=[];
    for tt = 1:size(clusterTh, 2)
        fi = find(clusterTh(:,tt),1,'first');
        if ~isempty(fi) 
            sigi(tt) = fi;
            sigt(tt) = ptime(fi);
            plot(sigt(tt), tt, '*w', 'MarkerSize', 4);
        else
            sigi(tt) = NaN;
            sigt(tt) = NaN;
        end
    end
    
    %Plot a colormap plot of the p-values
    axes(ah(ll+nsites));
    imagesc(sd.ET.freq(ff).loc(ll).time(pi), 1:size(clusterTp,2), clusterTp');
    ylim(ah(ll+nsites), [1 size(clusterTp,2)]);
    xlim(ah(ll+nsites), [-1 t(end)]);
    colorbar;
    ah(ll+nsites).YDir='reverse';
    
    % These will plot as overlying curves with means
    % plot(ah(ll), sd.ET.freq(ff).loc(ll).time(pi), sd.ET.freq(ff).loc(ll).perSessionZ(pi,:), 'color', [0.5 0.5 1], 'Linewidth', .5);  
%     plot(ah(ll), sd.PD.freq(ff).loc(ll).time(pi), sd.PD.freq(ff).loc(ll).perSessionZ(pi,:), 'color', [1 0.5 0.5], 'Linewidth', .5);
%     plot(ah(ll), sd.PD.freq(ff).loc(ll).time(pi), pd_mean(pi), 'color', [1 0 0], 'Linewidth', 2);    
%     plot(ah(ll), sd.ET.freq(ff).loc(ll).time(pi), et_mean(pi), 'color', [0 0 1], 'Linewidth', 2);
    
    ymax = max(max(sd.ET.freq(ff).loc(ll).perSessionZ(:)), max(sd.PD.freq(ff).loc(ll).perSessionZ(:)));
    ymin = min(min(sd.ET.freq(ff).loc(ll).perSessionZ(:)), min(sd.PD.freq(ff).loc(ll).perSessionZ(:)));
    %line(ah(ll), sd.ET.freq(ff).loc(ll).time, h*(ymax+1), 'Color', 'k', 'LineWidth', 1);
    %ylim(ah(ll), [floor(ymin-1) ceil(ymax+1.5)]);
    %xlim([-1 t(end)]);
    %histograms of mean response maximums/min by 
    if (ff==1 || ff==2)
       respfunc = @max;
    else 
       respfunc = @min;
    end
    
    axes(ah(ll+nsites));
    [et_resp, et_peaki] = respfunc(sd.ET.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    [pd_resp, pd_peaki] = respfunc(sd.PD.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
%     %h1 = histogram(pd_resp); hold on; h2 = histogram(et_resp);
%     h1 = histogram(t(t_wind(pd_peaki))); hold on; h2 = histogram(t(t_wind(et_peaki)));
%     %h1.BinWidth = 1; h2.BinWidth = 1;
%     h1.BinWidth = .2; h2.BinWidth = .2;
%     h1.FaceColor = [1 0 0]; h2.FaceColor = [0 0 1];
%     h1.Normalization = 'probability'; h2.Normalization = 'probability';
%     legend(['PD N=' num2str(pd_n)],['ET N=' num2str(et_n)]);    
%     tpd = median(t(t_wind(pd_peaki))); plot([tpd, tpd], [0 1], 'r');
%     tet = median(t(t_wind(et_peaki))); plot([tet, tet], [0 1], 'b');
%     [p_tpeak, h_tpeak] = ranksum(t(t_wind(pd_peaki)), t(t_wind(et_peaki)));
%     disp([sd.freq_labels{ff} ' ' sd.loc_labels{ll} 'PD median:' num2str(tpd) ' ETmedian:' num2str(tet)]);
%     disp(['Rank sum p=' num2str(p_tpeak) ' h=' num2str(h_tpeak)]);
  
%Gonna plot the min/max responses per electrode
    axes(ah2(ll));
    pdlabel = labelElectrodes(sd.PD.freq(ff).loc(ll).include);
    plot(1:length(pd_resp), pd_resp, 'xr'); hold on;
    x = length(pd_resp)+ (1:length(et_resp));
    plot(x, et_resp, 'ob');
    etlabel = labelElectrodes(sd.ET.freq(ff).loc(ll).include);
    xticks(1:sum([length(pd_resp), length(et_resp)]));
    xticklabels(cat(1, pdlabel, etlabel));
    xtickangle(90);
  end
  %saveas(fh, ['allsessions_' sd.freq_labels{ff}], 'epsc2');
  
  %fn = [figDir filesep 'allsessionsTiming_' sd.freq_labels{ff} '.eps'];
  %print(fn, '-depsc2', '-tiff', '-r300', '-painters');
end
