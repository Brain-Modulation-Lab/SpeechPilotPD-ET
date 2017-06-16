subjects = {'DBS4038', 'DBS4040', 'DBS4046', 'DBS4047', 'DBS4049', 'DBS4051', 'DBS4053', 'DBS4054', 'DBS4055', 'DBS4056'};

if ispc
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
    figDir = '\\136.142.16.9\Nexus\Users\pwjones\figureDump';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
    figDir = '~pwjones/Documents/RichardsonLab/SRP/figureDump';
end
if ispc
    
else
    
end

ref=1; %1 is common reference avg, 0 is unreferenced
h=1;
Results=[];
%%
for s=1:length(subjects)
    tmp=dir([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep subjects{s} '*.mat']);
    for fi=1:length(tmp)
        load([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep tmp(fi).name],'Ecog','trials','nfs','labels');
    
        viewEcogTrials;
    end
end