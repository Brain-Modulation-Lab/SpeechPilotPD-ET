% Plot the spectrograms for a session

ns = length(Results);
for ii = 1:ns
    trTime = linspace(-Results(ii).Onset.parameters{2}, Results(ii).Onset.parameters{4}, size(Results(ii).Onset.tr,2));
    fq=[2:2:200]';
    
    psd = abs(Results(ii).Onset.tr).^2;
    meanPSD = squeeze(nanmean(psd,3));
    nch = size(meanPSD,3);
    figure;
    for jj=1:nch %number of electrodes
        if nch == 6
            ah = subplot(nch, 1, nch-(jj-1));
        else
            ah = subplot(nch/2, 2, nch-(jj-1));
        end
        plotSpect(trTime, fq, meanPSD(:,:,jj), ah);
        set(ah, 'YScale', 'log');
        xlabel(ah, 'Time relative to Speech Onset (sec)');
        ylabel(ah, 'Frequency (Hz)');
    end
    title(Results(ii).Session);
end