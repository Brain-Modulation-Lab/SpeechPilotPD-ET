%Plot the mean for each session/electrode for each frequency 

sd = summaryData;
for ff=1:length(sd.freq_labels)
  [ah2, fh2] = subplot_pete(length(sd.loc_labels), 1, 'Electrode Number', 'Max/Min resp', sd.freq_labels{ff});
  set(fh2, 'Renderer', 'painters');
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
    t_wind = find(t>-.5 & t<2);
    
    et_max = max(sd.ET.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    et_min = min(sd.ET.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    
    hold on;
    %plot all of the responses by electrode/session
    plot(ah(ll), sd.ET.freq(ff).loc(ll).time(pi), sd.ET.freq(ff).loc(ll).perSessionZ(pi,:), 'color', [0.5 0.5 1], 'Linewidth', .5);  
    plot(ah(ll), sd.PD.freq(ff).loc(ll).time(pi), sd.PD.freq(ff).loc(ll).perSessionZ(pi,:), 'color', [1 0.5 0.5], 'Linewidth', .5);
    plot(ah(ll), sd.PD.freq(ff).loc(ll).time(pi), pd_mean(pi), 'color', [1 0 0], 'Linewidth', 2);    
    plot(ah(ll), sd.ET.freq(ff).loc(ll).time(pi), et_mean(pi), 'color', [0 0 1], 'Linewidth', 2);
    
    ymax = max(max(sd.ET.freq(ff).loc(ll).perSessionZ(:)), max(sd.PD.freq(ff).loc(ll).perSessionZ(:)));
    ymin = min(min(sd.ET.freq(ff).loc(ll).perSessionZ(:)), min(sd.PD.freq(ff).loc(ll).perSessionZ(:)));
    %line(ah(ll), sd.ET.freq(ff).loc(ll).time, h*(ymax+1), 'Color', 'k', 'LineWidth', 1);
    ylim(ah(ll), [floor(ymin-1) ceil(ymax+1.5)]);
    xlim([-1 t(end)]);
    %histograms of mean response maximums/min by 
    if (ff==1 || ff==2)
       respfunc = @max;
    else 
       respfunc = @min;
    end
    axes(ah(ll+nsites)); 
    [et_resp, et_peaki] = respfunc(sd.ET.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    [pd_resp, pd_peaki] = respfunc(sd.PD.freq(ff).loc(ll).perSessionZ(t_wind,:), [],1);
    %h1 = histogram(pd_resp); hold on; h2 = histogram(et_resp);
    h1 = histogram(t(t_wind(pd_peaki))); hold on; h2 = histogram(t(t_wind(et_peaki)));
    %h1.BinWidth = 1; h2.BinWidth = 1;
    h1.BinWidth = .2; h2.BinWidth = .2;
    h1.FaceColor = [1 0 0]; h2.FaceColor = [0 0 1];
    h1.Normalization = 'probability'; h2.Normalization = 'probability';
    legend(['PD N=' num2str(pd_n)],['ET N=' num2str(et_n)]);  
    
    tpd = median(t(t_wind(pd_peaki))); plot([tpd, tpd], [0 1], 'r');
    tet = median(t(t_wind(et_peaki))); plot([tet, tet], [0 1], 'b');
    [p_tpeak, h_tpeak] = ranksum(t(t_wind(pd_peaki)), t(t_wind(et_peaki)));
    disp([sd.freq_labels{ff} ' ' sd.loc_labels{ll} 'PD median:' num2str(tpd) ' ETmedian:' num2str(tet)]);
    disp(['Rank sum p=' num2str(p_tpeak) ' h=' num2str(h_tpeak)]);
    %Gonna plot the min/max responses per electrode
    axes(ah2(ll));
    plot(pd_resp, 'xr'); hold on;
    plot(et_resp, 'ob');
  end
  %saveas(fh, ['allsessions_' sd.freq_labels{ff}], 'epsc2');
  fn = [figDir filesep 'allsessionsTiming_' sd.freq_labels{ff} '.eps'];
  print(fn, '-depsc2', '-tiff', '-r300', '-painters');
end