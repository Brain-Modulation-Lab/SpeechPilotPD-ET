
freq={'delta','theta','alpha','beta1','beta2','Gamma','Hgamma'};
freq={'Hgamma', 'Gamma', 'beta1', 'beta2'};
colors = {'k', 'b', 'r', [1 .2 .2]}
ns = length(Results); 
ns=14;
cond = 'Onset';

for ii = 14:ns
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
                ah(jj) = subplot(nch, 1, nch-(jj-1));
            elseif nch > 12
                ncol = 2;
                nrow = nch/ncol;
                c = floor(jj/(nch/ncol))+1;
                r = mod(jj-1,nrow)+1;
                if ff==1
                    ah(jj) = axes('Position', [.05*c+(.8/ncol*(c-1)) .02*r+((r-1)*.8/nrow) .9/ncol .9/nrow]);
                end
            else
                ah(jj) = subplot(nch/2, 2, nch-(jj-1));
            end
            signal_ch = signal(:, jj:nch:s2);
            hold on;
            plot(ah(jj), trTime, mean(signal_ch,2),'Color', colors{ff}, 'LineWidth', 2);
            ylim([-2 5]);
            if ff==length(ff)
                if jj==1
                    xlabel(ah(jj), 'Time relative to Speech Onset (sec)');
                    ylabel(ah(jj), 'Z Score');
                end
                plot(trTime, -2*ones(length(trTime),1)','k--');
                plot(trTime, 2*ones(length(trTime),1)','k--');
            end
            %title([freq '-' cond ' aligned']);
            if jj==nch
                legend(freq);
            end
        end
    end
    title([Results(ii).Session ', ' cond ' aligned']);
end