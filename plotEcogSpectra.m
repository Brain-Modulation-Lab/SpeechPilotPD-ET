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
        
        %         tr = abs(Results(ii).Onset.tr);
        %         base = abs(Results(ii).Onset.base);
        %         psd = abs(Results(ii).Onset.tr);
        %         meanPSD = squeeze(nanmean(psd,3));
        %         nch = size(meanPSD,3);
        %         zsc = zeros(size(tr,1), size(tr,2), nch);
        %         for i=1:nch
        %             x=mean(tr(:,:,:,i),3); %trial avgs
        %             y=mean(base(:,:,:,i),3);
        %             zsc(:,:,i)=bsxfun(@rdivide,bsxfun(@minus,x,mean(y,2)),std(y,0,2));
        %         end
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
            plotSpect(trTime, fq, zsc(:,:,jj), ah(jj));
            %set(ah, 'YScale', 'log');
            if jj==1
                xlabel(ah(jj), ['Time relative to ' align_labels{aa} ' (sec)']);
                ylabel(ah(jj), 'Frequency (Hz)');
            end
            caxis([-5 7]); colorbar;
            set(gca, 'TickDir','out');
        end
        title(Results(ii).Session);
        session = strtok(Results(ii).Session,'.');
        saveas(gcf, sprintf('%s%sSpectrograms2%s%s-%s',figDir,filesep,filesep,session, align{aa}),'bmp');
    end
    
end