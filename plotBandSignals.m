
freq={'delta','theta','alpha','beta1','beta2','Gamma','Hgamma'};
freq={'Hgamma', 'Gamma', 'beta1', 'beta2'};
colors = {'k', 'b', 'r', [1 .2 .2]}
ns = length(Results);
cond = 'Onset';

for ii = 1:ns
    for ff = 1:length(freq)
        trTime = linspace(-Results(ii).Onset.parameters{2}, Results(ii).Onset.parameters{4}, size(Results(ii).Onset.tr,2));
        signal = Results(ii).(cond).(freq{ff}).z_Amp;
        
        nTrials = Results(ii).Cue.parameters{8};
        nch = size(signal,2)/nTrials;
        s2 = size(signal,2);
        if ff==1
            fh(ii) = figure;
        else
            figure(fh(ii));
        end
        
        for jj=1:nch %number of electrodes
            if nch == 6
                ah = subplot(nch, 1, nch-(jj-1));
            else
                ah = subplot(nch/2, 2, nch-(jj-1));
            end
            signal_ch = signal(:, jj:nch:s2);
            hold on;
            plot(trTime, mean(signal_ch,2),'Color', colors{ff}, 'LineWidth', 2);
            ylim([-2 5]);
            %set(ah, 'YScale', 'log');
            xlabel(ah, 'Time relative to Speech Onset (sec)');
            ylabel(ah, 'Z Score');
            %title([freq '-' cond ' aligned']);
            if jj==nch
                legend(freq);
            end
        end
    end
    title([Results(ii).Session ', ' cond ' aligned']);
end