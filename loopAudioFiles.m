%loop through all of the data directories

subjectLists;
setDirectories;
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
        sessionBehavior(n+1).snrVoice = computeLoudnessRMS(fname);
        [sessionBehavior(n+1).SpLatency, sessionBehavior(n+1).SpDuration] = responseTimingsFromCodingFile(fname);
        n = n+1;
    end
end