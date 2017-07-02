%subjects = {'DBS4038', 'DBS4040', 'DBS4046', 'DBS4047', 'DBS4049', 'DBS4051', 'DBS4053', 'DBS4054', 'DBS4055', 'DBS4056'};
subjectLists;
subjects = ET_subjects;

if ispc
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
    figDir = '\\136.142.16.9\Nexus\Users\pwjones\figureDump';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
    figDir = '~pwjones/Documents/RichardsonLab/SRP/figureDump';
end

%%
for s=1:length(subjects)
    tmp=dir([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep subjects{s} '*.mat']);
    for fi=1:length(tmp)
        EcogLabels = [];
        load([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep tmp(fi).name],'Ecog','trials','nfs','labels', 'EcogLabels', 'Session');
        if ~isempty(EcogLabels)
            labels = EcogLabels;
        end
        viewEcogTrials;
    end
end