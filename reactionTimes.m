% Analyze the reaction times of each session and the overall RTs
setDirectories;
load([savedDataDir filesep 'PD_sessionInfo.mat']);
nSessions = length(sessionInfo);

for ii=1:nSessions
    subj = strtok(sessionInfo(ii).name, '_. ');
    load([datadir filesep subj filesep 'Preprocessed Data' filesep sessionInfo(ii).name], 'trials');
    % now look at RTs
    used = sessionInfo(ii).params{10};
    SpOnset = trials.SpOnset(used);
    Command = trials.CommandStim(used);
    rts = SpOnset(:) - Command(:);
    rtCell{ii} = rts;
    mean_rt(ii) = mean(rts);
end
