% Analyze the reaction times of each session and the overall RTs
setDirectories;
load('PD_sessionInfo.mat')
nSessions = 1:length(sessionInfo);

for ii=1:nSessions
    subj = strtok(sessionInfo(ii).name, '_. ');
    trials = load([datadir filesep subj filesep 'Preprocessed Data' filesep sessionInfo(ii).name], 'trials');
    % now look at RTs
end
