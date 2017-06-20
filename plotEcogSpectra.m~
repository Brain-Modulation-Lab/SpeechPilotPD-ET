% Plot the spectrograms for a session

ns = length(Results);
for ii = 1:ns
    trTime = linspace(-Results(ii).Onset.parameters{2}, Results(ii).Onset.parameters{4}, size(Results(ii).Onset.tr,2));
    fq=[2:2:200]';
    tr = abs(Results(ii).Onset.tr);
    base = abs(Results(ii).Onset.base);
    psd = abs(Results(ii).Onset.tr).^2;
    meanPSD = squeeze(nanmean(psd,3));
    nch = size(meanPSD,3);
    zsc = zeros(size(tr,1), size(tr,2), ch);
    for i=1:ch
        x=mean(tr(:,:,:,i),3); %trial avgs
        y=mean(base(:,:,:,i),3);
        zsc(:,:,i)=bsxfun(@rdivide,bsxfun(@minus,x,mean(y,2)),std(y,0,2));
    end
    
    figure;
    for jj=1:nch %number of electrodes
        if nch == 6
            ah = subplot(nch, 1, nch-(jj-1));
        else
            ah = subplot(nch/2, 2, nch-(jj-1));
        end
        plotSpect(trTime, fq, zsc(:,:,jj), ah);
        %set(ah, 'YScale', 'log');
        xlabel(ah, 'Time relative to Speech Onset (sec)');
        ylabel(ah, 'Frequency (Hz)');
    end
    title(Results(ii).Session);
end