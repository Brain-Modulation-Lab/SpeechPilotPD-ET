%loop through all of the data directories

subjectLists;
setDirectories;
clear sessionBehavior;
subjects = PD_subjects;


n = 0;
for s = 1:length(subjects)
    d = [datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'AudioCodingFiles'];
    if isdir([d filesep 'CHECKED'])
        d = [d filesep 'CHECKED'];
    end
    files = dir([d filesep 'DBS*']);
    for ii = 1:length(files)
        fname = [d filesep files(ii).name];
        load(fname);
        sessionBehavior(n+1).session = files(ii).name;
        [lat, dur, commandTimes] = responseTimingsFromCodingFile(files(ii).name, Audio, Afs, CodingMatrix, EventTimes, SkipEvents);
        snrVoice = computeLoudnessRMS(Audio, Afs, lat, dur, commandTimes);
        sessionBehavior(n+1).SpLatency = lat;
        sessionBehavior(n+1).SpDuration = dur;
        sessionBehavior(n+1).snrVoice = snrVoice;
        
        n = n+1;
    end
end

%save('PD_populationBehavior.mat', 'sessionBehavior', '-v7.3');