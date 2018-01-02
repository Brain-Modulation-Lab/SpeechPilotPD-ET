% Plot the spectrograms for a session
setDirectories;
align = {'Cue', 'Onset'};
align_labels = {'Cue Presentation', 'Speech Onset'};
ns = length(Results);
for ii = 1:ns
    fq=[2:2:200]';
    for aa=1:length(align)
        trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).zsc,2));
        zsc = Results(ii).(align{aa}).zsc;
        nch = size(zsc,3);
        
        % Note the mean timings of events - need to mark them on plots
        trialsUsed = Results(ii).Cue.parameters{10}; trialsUsed = trialsUsed(:);
        respTime = reshape(Results(ii).trials.SpOnset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed), [],1);
        respOffset = reshape(Results(ii).trials.SpOffset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed),[],1);
        if strcmp(align{aa}, 'Cue') %save event times for averaging/marking traces 
            meanEventTimes.(align{aa})(ii,:) = [0 mean(respTime) mean(respOffset)];
        else
            meanEventTimes.(align{aa})(ii,:) = [-mean(respTime) 0 mean(respOffset-respTime)];
        end
        
        fh = figure('Units', 'pixels', 'Position', [100 25 800 900]);
        for jj=1:nch %number of electrodes
            if nch == 6
                ncol = 1;
            elseif nch > 28
                ncol = 3;
            else
                ncol = 2;
            end
            nrow = ceil(nch/ncol);
            c = floor(((jj-1)/nrow)+1);
            r = mod(jj-1,nrow)+1;
            ah(jj) = axes('Position', [.05*c+(.8/ncol*(c-1)) .9*(.05+.02*r+((r-1)*.75/nrow)) .85/ncol .9*(.75/nrow)]);
            plotSpect(trTime, fq, zsc(:,:,jj), ah(jj));
            eventPlotx = repmat(meanEventTimes.(align{aa})(ii,:), 2,1);
            yl = [fq(1) fq(1) fq(1); fq(end) fq(end) fq(end)];
            hold on;
            plot(eventPlotx, yl, 'k', 'LineWidth', .5);
            %set(ah, 'YScale', 'log');
            if r==1
                xlabel(ah(jj), ['Time relative to ' align_labels{aa} ' (sec)']);
                ylabel(ah(jj), 'Frequency (Hz)');
            else
                ah(jj).XTickLabel = {};
            end
            if c~=1
                ah(jj).YTickLabel = {};
            end
            caxis([-7 10]); colorbar;
            set(gca, 'TickDir','out');
        end
        title(Results(ii).Session);
        session = strtok(Results(ii).Session,'.');
        %saveas(gcf, sprintf('%s%sSpectrograms2%s%s-%s',figDir,filesep,filesep,session, align{aa}),'bmp');
        %close(fh);
    end
    
end