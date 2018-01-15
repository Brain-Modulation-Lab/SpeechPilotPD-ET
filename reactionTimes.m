% Analyze the reaction times of each session and the overall RTs
setDirectories;
load([savedDataDir filesep 'PD_populationBehavior.mat']);
nSessionsPD = length(sessionBehavior);
ET = load([savedDataDir filesep 'ET_populationBehavior.mat']);
sessionBehavior = [sessionBehavior ET.sessionBehavior];
nSessions = length(sessionBehavior);
labels = zeros(nSessions, 1);
labels(1:nSessionsPD) = 1;

allLatsM = NaN*zeros(60, nSessions);
allDurM = NaN*zeros(60, nSessions);
allSNRM = NaN*zeros(60, nSessions);
for ii=1:nSessions
    subj = strtok(sessionBehavior(ii).session, '_. ');
    %load([datadir filesep subj filesep 'Preprocessed Data' filesep sessionInfo(ii).name], 'trials');
    % now look at RTs
    lats = sessionBehavior(ii).SpLatency;
    allLatsM(:,ii) = lats(:);
    allDurM(:,ii) = sessionBehavior(ii).SpDuration;
    allSNRM(:,ii) = sessionBehavior(ii).snrVoice;
end

%% Population reaction time characterization for each group
PDlat = [sessionBehavior(labels==1).SpLatency];
ETlat = [sessionBehavior(labels==0).SpLatency];
figure; histogram(PDlat);

%%
figure;
boxplot(allLatsM, labels, 'notch', 'on'); title('Response Latencies by Session');
figure;
boxplot(allDurM, labels, 'notch', 'on');  title('Response Duration by Session');
figure;
boxplot(allSNRM, labels, 'notch', 'on');  title('Voice RMS SNR by session');
