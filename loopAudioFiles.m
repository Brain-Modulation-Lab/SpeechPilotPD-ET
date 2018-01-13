%loop through all of the data directories

subjectLists;
setDirectories;
clear sessionBehavior;
subjects = ET_subjects;
n = 0;
for s = 3:length(subjects)
    d = [datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'AudioCodingFiles'];
    if isdir([d filesep 'CHECKED'])
        d = [d filesep 'CHECKED'];
    end
    files = dir([d filesep 'DBS*']);
    for ii = 1:length(files)
        fname = [d filesep files(ii).name];
        load(fname);
        sessionBehavior(n+1).snrVoice = computeLoudnessRMS(Audio, Afs, trials);
        [sessionBehavior(n+1).SpLatency, sessionBehavior(n+1).SpDuration] = responseTimingsFromCodingFile(trials);
        sessionBehavior(n+1).session = files(ii).name;
        n = n+1;
    end
end

save('ET_populationBehavior.mat', 'sessionBehavior', '-v7.3');