% ft_compilePopulationBehavior.m
% Just goes through the behavior for a group of subjects. Much of this is embedded
% in the epoch table (latency, timing). However, the loudness (RMS) needs
% to loop through each of the subject folders. 

subjectLists;
setDirectories;
clear sessionBehavior;
group = 'PD';
subjects = PD_subjects;
poolSessions = 0;

if poolSessions
    poolTag = '_pooledSessions';
else
    poolTag = '';
end
fn = fullfile(savedDataDir, 'population', ['Pop_ecog_' group '_hgamma.mat']);
load(fn);
clear sessionBehavior;
for n=1:length(popData)
        sessionBehavior(n).session = popData(n).session;
        sessionBehavior(n).subject = popData(n).subject;
        
        %[lat, dur, commandTimes] = responseTimingsFromCodingFile(files(ii).name, Audio, Afs, CodingMatrix, EventTimes, SkipEvents);
        trialID = popData(n).epoch.id;
        lat = popData(n).epoch.onset_word - popData(n).epoch.stimulus_starts;
        dur = popData(n).epoch.offset_word - popData(n).epoch.onset_word;
        commandTimes = popData(n).epoch.stimulus_starts;
        %snrVoice = computeLoudnessRMS(Audio, Afs, lat, dur, commandTimes);
        sessionBehavior(n).SpLatency = lat;
        sessionBehavior(n).SpDuration = dur;
        %sessionBehavior(n).snrVoice = snrVoice;
        sessionBehavior(n).trialID = trialID;
end

save('PD_populationBehavior.mat', 'sessionBehavior', '-v7.3');