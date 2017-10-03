% plot the responses for each electrode in the results trial

align = 'Cue';
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
figure;
rows = ceil(length(freq)/2);


for ff = 1:length(freq) %frequency bands/plots
    for ii=1:length(Results) %subjects
        nTrials = Results(ii).(align).parameters{8};
        nch = Results(ii).(align).parameters{12};
        trTime = linspace(-Results(ii).(align).parameters{2}, Results(ii).(align).parameters{4}, size(Results(ii).(align).zsc,2));
        base = abs(Results(ii).((align)).(freq{ff}).bs);
        signal = abs(Results(ii).((align)).(freq{ff}).tr);
        
        for jj=1:nch  %electrode contacts
            signal_ch = signal(:,jj:nch:end);
            base_ch = base(:,jj:nch:end);
            z_amp = (signal_ch - mean(mean(base_ch,2))) / std(mean(base_ch,2));
            mean_z = mean(z_amp,2);
            if isequal(freq{ff}, 'BroadbandGamma')
                gamma_max(ii, jj) =  max(mean_z);
            end
            
            if gamma_max(ii,jj) >= 5
                subplot(rows, 2, ff);
                plot(trTime, mean_z, 'k'); hold on;
            end
        end
    end
    plot([trTime(1) trTime(end)], [3 3], '--r', 'LineWidth', 1);
    plot([trTime(1) trTime(end)], [-3 -3], '--r', 'LineWidth', 1);
    title(freq{ff});
    set(gca, 'Ylim', [-10 10]);
end

     