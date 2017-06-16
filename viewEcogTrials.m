% View Ecog trials
% if ispc
%     codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
% else
%     codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
% end
load([codeDir filesep 'Filters' filesep 'highoass_2Hz_fs1200.mat']);

nch = size(Ecog,2);
%signal = filtfilt(hpFilt,Ecog);
for ii=1:nch
    figure;
    chan = signal(:,ii);
    chan = chan-mean(chan);
    amp = 3*nanstd(chan);
    
    trialEnd = round((mean(trials.SpOffset - trials.CommandStim) + .5)*nfs);
    trialBegin = nfs*-1;
    trialTime = (trialBegin:trialEnd)/nfs;
    commands = round(nfs*trials.CommandStim);
    for jj=1:60
        trialInds = commands(jj)+(trialBegin:trialEnd);
        if any(trialInds<1)
            fprintf('trialInds is neg on trial %d\n', jj);
        end
        hold on;
        plot(trialTime, chan(trialInds)-amp*(jj-1),'k');
    end
    xlabel('Time from Word Presentation (s)');
    ylabel('2Hz HP Filtered EEG');
    title(sprintf('LFP in trials %s - %s', subjects{s}, labels{ii}));
    saveas(gcf, [figDir filesep 'EEGtrials' filesep subjects{s} '-' labels{ii}], 'bmp');
end
    
    
    