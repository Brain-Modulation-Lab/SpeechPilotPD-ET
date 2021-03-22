% Want to compare/plot population ET versus PD groups for all locations
% frequency bands
poolSessions = 1;
alignOnset = 1;
setDirectories;

if (poolSessions) poolTag = '_pooledSessions'; else poolTag = ''; end
if (~alignOnset) alignTag = '_alignCue'; else alignTag = '_alignOnset'; end
load(fullfile(savedDataDir, 'population', ['summaryData_EcoG_BandAnalysis2' alignTag poolTag '.mat']));

sd = summaryData;
for ff=1:length(sd.freq_labels)
    if alignOnset
        [ah, fh] = subplot_pete(length(sd.loc_labels), 1, 'Time from speech onset (sec)', 'Z-score resp', sd.freq_labels{ff});
    else
        [ah, fh] = subplot_pete(length(sd.loc_labels), 1, 'Time from cue to speak (sec)', 'Z-score resp', sd.freq_labels{ff});
    end
    for ll=1:length(sd.loc_labels)
        title(ah(ll), sd.loc_labels{ll});
        
        %     if poolSessions % Only use this if using the ft_populationsBandAnalysis_pooledSessions.m
        %         [h,p] = clusterPermuteTtest(sd.PD.freq(ff).loc(ll).meanZ_subj', ...
        %             sd.ET.freq(ff).loc(ll).perSessionZ', 0.075);
        %         pd_mean = nanmean(sd.PD.freq(ff).loc(ll).meanZ_subj,2);
        %         npd = size(sd.PD.freq(ff).loc(ll).meanZ_subj,2);
        %         et_mean = nanmean(sd.ET.freq(ff).loc(ll).meanZ_subj,2);
        %         net = size(sd.ET.freq(ff).loc(ll).meanZ_subj,2);
        %         pd_sem = nanstd(sd.PD.freq(ff).loc(ll).meanZ_subj,0,2) ./ sqrt(npd);
        %         et_sem = nanstd(sd.ET.freq(ff).loc(ll).meanZ_subj,0,2) ./ sqrt(net);
        %     else
        %Test the period of the population signal difference from the
        %baseline
        sd.PD.freq(ff).loc(ll).perSessionZ'
        % Test the difference between PD and ET subjects
        [h,p] = clusterPermuteTtest(sd.PD.freq(ff).loc(ll).perSessionZ', ...
            sd.ET.freq(ff).loc(ll).perSessionZ', 0.075);
        pd_mean = nanmean(sd.PD.freq(ff).loc(ll).perSessionZ,2);
        npd = size(sd.PD.freq(ff).loc(ll).perSessionZ,2);
        et_mean = nanmean(sd.ET.freq(ff).loc(ll).perSessionZ,2);
        net = size(sd.ET.freq(ff).loc(ll).perSessionZ,2);
        pd_sem = nanstd(sd.PD.freq(ff).loc(ll).perSessionZ,0,2) ./ sqrt(npd);
        et_sem = nanstd(sd.ET.freq(ff).loc(ll).perSessionZ,0,2) ./ sqrt(net);
        %     end
        
        t = sd.ET.freq(ff).loc(ll).time;
        plot_err_poly(ah(ll), sd.ET.freq(ff).loc(ll).time, et_mean, et_sem, [0 0 1], [.5 .5 1],1);
        hold on;
        plot_err_poly(ah(ll), sd.PD.freq(ff).loc(ll).time, pd_mean, pd_sem, [1 0 0], [1 .5 .5],1);
        ymax = max(max(et_mean), max(pd_mean));
        ymin = min(min(et_mean), min(pd_mean));
        line(ah(ll), sd.ET.freq(ff).loc(ll).time, h*(ymax+1), 'Color', 'k', 'LineWidth', 1);
        ylim(ah(ll), [floor(ymin-1) ceil(ymax+1.5)]);
        xlim(ah(ll), [-1.5 t(end)]);
        
        %just give some report of the results
        disp(['Significantly different time periods for ', sd.freq_labels{ff}, '  ', sd.loc_labels{ll}]);
        segs = bwlabel(h);
        nsegs = max(segs);
        for ii=1:nsegs
            t = sd.ET.freq(ff).loc(ll).time(segs==ii);
            disp([num2str(t(1)) '  ' num2str(t(end))]);
        end
    end
    set(fh, 'Renderer', 'painters');
    saveas(fh, [figDir filesep 'ft_' sd.freq_labels{ff} alignTag poolTag], 'epsc2');
end

