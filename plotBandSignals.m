
freq={'delta','theta','alpha','beta1','beta2','Gamma','Hgamma'};
freq='Hgamma';
ns = length(Results);
cond = 'Onset';

for ii = 1:ns
    trTime = linspace(-Results(ii).Onset.parameters{2}, Results(ii).Onset.parameters{4}, size(Results(ii).Onset.tr,2));
    signal = Results(ii).(cond).(freq).z_Amp;
    
    nTrials = Results(ii).Cue.parameters{8};
    nch = size(signal,2)/nTrials;
    s2 = size(signal,2);
    figure;
    for jj=1:nch %number of electrodes
        ah = subplot(nch, 1, nch-(jj-1));
        signal_ch = signal(:, jj:nch:s2);
        hold on;
        plot(trTime, mean(signal_ch,2));
        ylim([-1 4]);
        %set(ah, 'YScale', 'log');
        xlabel(ah, 'Time relative to Speech Onset (sec)');
        ylabel(ah, 'Z Score');
        %title([freq '-' cond ' aligned']);
    end
    title([Results(ii).Session ', ' freq '-' cond ' aligned']);
end