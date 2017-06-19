% Just setup the directories for data, etc
if ispc
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
    figDir = '\\136.142.16.9\Nexus\Users\pwjones\figureDump';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
    figDir = '~pwjones/Documents/RichardsonLab/SRP/figureDump';
end
