% View Ecog trials

load([codeDir filesep 'Filters' filesep 'highoass_2Hz_fs1200.mat']);
disp('HP filtering signal');
nch = size(Ecog,2);
signal = filtfilt(hpFilt,Ecog); %2 Hz low pass filtering
signal= bsxfun(@minus,signal,mean(signal,2));  %common reference averaging
trRange = 1:60;
for ii=1:nch
    fh = figure;
    chan = signal(:,ii);
    chan = chan-mean(chan);
    stdChan = nanstd(chan);
    normVal = 4 * stdChan;
    
    if isfield(trials, 'SpOffset')
        SpOffset = trials.SpOffset(:); %this is bc some of the data are inconsistently dimensioned
    else 
        SpOffset = trials.SpEnd(:);
    end
    CommandStim = trials.CommandStim(:);
    trialEnd = round((nanmean(SpOffset(trRange) - CommandStim(trRange)) + .5)*nfs);
    trialBegin = nfs*-1;
    trialTime = (trialBegin:trialEnd)/nfs;
    trialDur = (trialEnd-trialBegin)/nfs;
    commands = round(nfs*CommandStim(trRange));
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
    set(gca, 'ydir', 'reverse', 'TickDir','out');
    title(sprintf('LFP in trials %s - %s', subjects{s}, labels{ii}));
    saveas(gcf, sprintf('%s%sCRA_EEGtrials%s%s-Session%d-%s',figDir,filesep,filesep,subjects{s},strtok(tmp(fi).name,'.'),labels{ii}),'bmp');
    close(fh);
end
    
    
    