% View Ecog trials
% if ispc
%     codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
% else
%     codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
% end
load([codeDir filesep 'Filters' filesep 'highoass_2Hz_fs1200.mat']);

nch = size(Ecog,2);
signal = filtfilt(hpFilt,Ecog);
for ii=1:nch
    figure;
    chan = signal(:,ii);
    chan = chan-mean(chan);
    stdChan = nanstd(chan);
    normVal = 3 * stdChan;
    
    trialEnd = round((nanmean(trials.SpOffset - trials.CommandStim) + .5)*nfs);
    trialBegin = nfs*-1;
    trialTime = (trialBegin:trialEnd)/nfs;
    commands = round(nfs*trials.CommandStim);
    text(-.5, -5, sprintf('Std: %f', stdChan), 'FontSize', 16); 
    for jj=1:60
        trialInds = commands(jj)+(trialBegin:trialEnd);
        if any(trialInds<1)
            fprintf('trialInds is neg on trial %d\n', jj);
        end
        hold on;
        plot(trialTime, chan(trialInds)./normVal+(jj-1),'k');
    end
    xlabel('Time from Word Presentation (s)');
    ylabel('2Hz HP Filtered EEG');
    set(gca, 'ydir', 'reverse');
    title(sprintf('LFP in trials %s - %s', subjects{s}, labels{ii}));
    saveas(gcf, sprintf('%s%sEEGtrials%s%s-Session%d-%s',figDir,filesep,filesep,subjects{s},Session,labels{ii}),'bmp');
end
    
    
    