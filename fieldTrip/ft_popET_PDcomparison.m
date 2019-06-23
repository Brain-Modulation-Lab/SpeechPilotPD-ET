% Want to compare/plot population ET versus PD groups for all locations 
% frequency bands
sd = summaryData;
for ff=1:length(sd.freq_labels)
  figure;
  for ll=1:length(sd.loc_labels)
    ah(ll) = subplot(length(sd.loc_labels),1, ll);
    title(sd.loc_labels{ff});
    
    [h,p] = clusterPermuteTtest(sd.PD.freq(ff).loc(ll).perSessionZ', ...
                                sd.ET.freq(ff).loc(ll).perSessionZ');
    pd_mean = nanmean(sd.PD.freq(ff).loc(ll).perSessionZ,2);
    npd = size(sd.PD.freq(ff).loc(ll).perSessionZ,2);
    et_mean = nanmean(sd.ET.freq(ff).loc(ll).perSessionZ,2);
    net = size(sd.ET.freq(ff).loc(ll).perSessionZ,2);
    pd_sem = nanstd(sd.PD.freq(ff).loc(ll).perSessionZ,0,2) ./ sqrt(npd);
    et_sem = nanstd(sd.ET.freq(ff).loc(ll).perSessionZ,0,2) ./ sqrt(net);
    
    plot_err_poly(gca, sd.ET.freq(ff).loc(ll).time, et_mean, et_sem, [0 0 1], [.5 .5 1],1);
    hold on;
    plot_err_poly(gca, sd.PD.freq(ff).loc(ll).time, pd_mean, pd_sem, [1 0 0], [1 .5 .5],1);
  end
end

  