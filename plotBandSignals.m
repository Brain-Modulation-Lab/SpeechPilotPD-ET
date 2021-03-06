setDirectories;
align = {'Cue', 'Onset'};
align_labels = {'Cue Presentation', 'Speech Onset'};
ns = length(Results);

freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
%freq={'BroadbandGamma','beta1','beta2','alpha','theta','delta'};
colors = {'k','r', [1 .3 .3], 'b',[.5 .5 .5], 'y','g', 'c','m'};
%freq={'BroadbandGamma','beta1','beta2','delta','theta','alpha'};
%colors = {'k', 'r', [1 .3 .3], 'y','g','c','m'};
%freq={'BroadbandGamma', 'beta1', 'beta2'};

ns = length(Results); 
meanEventTimes = [];
for ii = 1:ns
    ph = []; h=1;
    for aa=1:length(align)
        % Note the mean timings of events - need to mark them on plots
        trialsUsed = Results(ii).Cue.parameters{10}; trialsUsed = trialsUsed(:);
        respTime = reshape(Results(ii).trials.SpOnset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed), [],1);
        respOffset = reshape(Results(ii).trials.SpOffset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed),[],1);
        if strcmp(align{aa}, 'Cue') %save event times for averaging/marking traces 
            meanEventTimes.(align{aa})(ii,:) = [0 mean(respTime) mean(respOffset)];
        else
            meanEventTimes.(align{aa})(ii,:) = [-mean(respTime) 0 mean(respOffset-respTime)];
        end
        
        for ff = 1:length(freq)
            nTrials = Results(ii).(align{aa}).parameters{8};
            nch = Results(ii).(align{aa}).parameters{12};
            trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).zsc,2)); 
            %signal = Results(ii).((align{aa})).(freq{ff}).z_Amp;
            base = abs(Results(ii).((align{aa})).(freq{ff}).bs);
            signal = abs(Results(ii).((align{aa})).(freq{ff}).tr);
            
            if ff==1
                fh(ii) = figure('Units', 'pixels', 'Position', [100 25 600 850]);
            else
                figure(fh(ii));
            end
            
            for jj=1:nch %number of electrodes
                if nch == 6
                    ah(jj) = subplot(nch, 1, nch-(jj-1));
                elseif nch > 33
                    ncol = 3;
                    nrow = nch/ncol;
                    c = floor(jj/(nch/ncol))+1;
                    r = mod(jj-1,nrow)+1;
                    if ff==1
                        ah(jj) = axes('Position', [.05*c+(.8/ncol*(c-1)) .02*r+((r-1)*.8/nrow) .9/ncol .9/nrow]);
                    end
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
                signal_ch = signal(:,jj:nch:end);
                base_ch = base(:,jj:nch:end);
                z_amp = (signal_ch - mean(mean(base_ch,2))) / std(mean(base_ch,2));
                hold on;
                ph(h) = plot(ah(jj), trTime, mean(z_amp,2),'Color', colors{ff}, 'LineWidth', 2);
                yl = [-10 15];
                ylim([yl(1) yl(2)]);
                xlim([trTime(1) trTime(end)]);
                
                eventPlotx = repmat(meanEventTimes.(align{aa})(ii,:), 2,1);
                yl = [yl(1) yl(1) yl(1); yl(end) yl(end) yl(end)];
                plot(ah(jj),eventPlotx, yl, 'k', 'LineWidth', .5);
                if ff==length(ff)
                    if jj==1
                        xlabel(ah(jj), ['Time relative to ' align_labels{aa} ' (sec)']);
                        ylabel(ah(jj), 'Z Score');
                    end
                    plot(trTime, -3*ones(length(trTime),1)','k--');
                    plot(trTime, 3*ones(length(trTime),1)','k--');
                    
                end
                %title([freq '-' cond ' aligned']);
                if jj==nch && ff == length(freq)
                    legend(ph(1:nch:end), freq,'Location','northwest','Orientation','horizontal');
                end
                h = h+1;
            end
        end
        
        title([Results(ii).Session ', ' align{aa} ' aligned']);
        session = strtok(Results(ii).Session,'.');
        %saveas(gcf, sprintf('%s%sBandpassSignals%s%s-%s',figDir,filesep,filesep,session,align{aa}),'bmp');
    end
end