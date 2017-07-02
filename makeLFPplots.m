

cueT = data.trials.BaseBack(1:60);
endT=data.trials.ITIStim(1:60);
endT = endT(:);
prestim=round(1*data.nfs); %one second back from cue  
poststim=round(1+mean(endT-cueT)*data.nfs); %mean trial length
plotTime = (-prestim:poststim)./data.nfs;
trial=arrayfun(@(x) input(x-prestim:x+poststim,:),round(cueT*data.nfs),'Uni',0);
trialM = permute(cat(3,trial{:}), [1 3 2]); %time x trial x channel
rejectTrials = [reject, artifact];
ah = plotEcogChannelTrials(plotTime, trialM, rejectTrials, chUsed);
for ii=1:length(ah)
    title(ah(ii),sprintf('LFP in trials %s - %s', subjects{s}, data.labels{chUsed(ii)}));
    saveas(ah(ii).Parent, sprintf('%s%sCRA_EEGtrials%s%s-Session%d-%s',figDir,filesep,filesep,subjects{s},strtok(tmp(fi).name,'.'),data.labels{chUsed(ii)}),'bmp');
    close(ah(ii).Parent);
end