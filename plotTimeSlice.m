% Plot the spectrograms for a session
setDirectories;
align = {'Onset'};
align_labels = {'Speech Onset'};
ns = length(Results);
for ii = 1:ns
    fq=[2:2:200]';
    for aa=1:length(align)
        trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).zsc,2));
        zsc = Results(ii).(align{aa}).zsc;
        nch = size(zsc,3);
        tind = find(trTime >= .4, 1,'first');
        
        figure('Units', 'pixels', 'Position', [100 25 600 850]);
        for jj=1:nch %number of electrodes
            if nch == 6
                ah(jj) = subplot(nch, 1, nch-(jj-1));
            elseif nch > 12
                ncol = 2;
                nrow = nch/ncol;
                c = floor(jj/(nch/ncol))+1;
                r = mod(jj-1,nrow)+1;
                ah(jj) = axes('Position', [.05*c+(.8/ncol*(c-1)) .02*r+((r-1)*.8/nrow) .9/ncol .9/nrow]);
            else
                ah(jj) = subplot(nch/2, 2, nch-(jj-1));
            end
            plot( ah(jj), fq, zsc(tind,:,jj),'k', 'LineWidth', 2);
            %set(ah, 'YScale', 'log');
            if jj==1
                ylabel(ah(jj), 'Z scored signal amplitude');
                xlabel(ah(jj), 'Frequency (Hz)');
            end
            set(gca, 'TickDir','out');
        end
        title(Results(ii).Session);
        session = strtok(Results(ii).Session,'.');
        %saveas(gcf, sprintf('%s%sSpectrograms2%s%s-%s',figDir,filesep,filesep,session, align{aa}),'bmp');
    end
    
end