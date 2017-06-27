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
            %set(ah, 'YScale', 'log');
            if r==1
                xlabel(ah(jj), ['Time relative to ' align_labels{aa} ' (sec)']);
                ylabel(ah(jj), 'Frequency (Hz)');
            else
                xticklabels({});
            end
            if c~=1
                yticklabels({});
            end
            caxis([-5 7]); colorbar;
            set(gca, 'TickDir','out');
        end
        title(Results(ii).Session);
        session = strtok(Results(ii).Session,'.');
        saveas(gcf, sprintf('%s%sSpectrograms2%s%s-%s',figDir,filesep,filesep,session, align{aa}),'bmp');
        close(fh);
    end
    
end