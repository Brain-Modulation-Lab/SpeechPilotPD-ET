function ah = plotEcogChannelTrials(time, signal, rejectedTrials, artifactTrials, channelUsed)
%function plotEcogChannel(ah, signal, rejected)
%
% ah - axes handle
% signal - time x trial x channel matrix
% fs - sampling rate (Hz)
% rejected - rejected trials, to be plotted in red

nt = size(signal,2);
nch = size(signal,3);
%time = ((1:size(signal,1))-1) / fs; 

for ii=1:nch
    fh(ii) = figure; hold on;
    stdChan = mean(nanstd(signal(:,:,ii),0,1));
    for jj=1:nt
        ph = plot(time, signal(:,jj,ii)./(stdChan*4) - jj, 'k');
        if any(jj==artifactTrials) 
                set(ph, 'Color', 'r'); 
        elseif any(jj==rejectedTrials)
                set(ph, 'Color', 'b');
        end
    end
    ah(ii) = get(ph, 'Parent');
    xlabel('Time from Word Presentation (s)');
    ylabel('2Hz HP Filtered ECoG');
    text(-.5, 3, sprintf('Std: %f', stdChan), 'FontSize', 16); 
    set(ah(ii), 'TickDir','out');
    ylim([-62 5]);
end
