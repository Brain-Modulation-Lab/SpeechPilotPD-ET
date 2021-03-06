setDirectories; %platform specific locations 
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
subjectLists; %load lists of subjects
subjects = ET_subjects;
%subjects = PD_subjects(6:end);
group = 'ET';

% Behavioral Measures!
ET = load([savedDataDir filesep 'ET_populationBehavior.mat']);
sessionBehavior = ET.sessionBehavior;
nSessions = length(sessionBehavior);
allLatsM = NaN*zeros(60, nSessions); %size is 60 trials x number of behavioral sessions in dataset
allDurM = NaN*zeros(60, nSessions);
allSNRM = NaN*zeros(60, nSessions);
session =[];
for ii=1:nSessions
    subj = strtok(sessionBehavior(ii).session, '_. ');
    session{ii} = strtok(sessionBehavior(ii).session, ' ');
    
    %load([datadir filesep subj filesep 'Preprocessed Data' filesep sessionInfo(ii).name], 'trials');
    % now look at RTs
    lats = sessionBehavior(ii).SpLatency;
    allLatsM(:,ii) = lats(:);
    allDurM(:,ii) = sessionBehavior(ii).SpDuration;
    allSNRM(:,ii) = 20*log10(sessionBehavior(ii).snrVoice); %SNR db as in SLP matlab book
end

for ii=1:length(Results)
    match = arrayfun(@(x) strcmpi(strtok(Results(ii).Session, '.'),x), session);
    matchi = find(match,1, 'first');
    if ~isempty(matchi)
        tr = Results(ii).trialInds;
        vol = allSNRM(tr, matchi);
        resp = Results(ii).MaxZ(1:length(tr),Results(ii).Channel);
        [rhovol(ii), corrpval(ii)] = corr(vol, resp);
        dur = allDurM(tr, matchi);
        [rhodur(ii), corrpval(ii)] = corr(dur, resp);
        lat = allLatsM(tr, matchi);
        [rholat(ii), corrpval(ii)] = corr(lat, resp);
        Csig(ii) = Results(ii).pvalCpearson < 0.05;
        Ssig(ii) = Results(ii).pvalSpearson < 0.05;
    end
end

locations = {'Precentral Gyrus', 'Postcentral Gyrus', 'Superior Temporal Gyrus'};
for ii=1:length(locations)
    locmatch = arrayfun(@(x) strcmp(locations{ii}, x.Locations), Results);
    inc = locmatch & (Csig | Ssig);
    
end