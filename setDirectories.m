% Just setup the directories for data, etc
if ispc
    docDir = '\\136.142.16.9\Nexus\Users\pwjones\code\ET-PD project';
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
    figDir = '\\136.142.16.9\Nexus\Users\pwjones\figureDump';
    savedDataDir = '\\136.142.16.9\Nexus\Users\pwjones\code\DataFiles';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
    docDir = '~pwjones/Documents/RichardsonLab/ET-PD project';
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
    figDir = '~pwjones/Documents/RichardsonLab/SRP/figureDump';
    savedDataDir = '/Volumes/ToughGuy/RichardsonLabData/ET';
end
