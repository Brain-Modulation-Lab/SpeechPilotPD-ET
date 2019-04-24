% Just setup the directories for data, etc
if ispc
    docDir = '\\136.142.16.9\Nexus\Users\pwjones\docs\ET-PD project';
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\136.142.16.9\Nexus\DBS';
    figDir = '\\136.142.16.9\Nexus\Users\pwjones\figureDump';
    savedDataDir = '\\136.142.16.9\Nexus\Users\pwjones\data';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
    docDir = '~pwjones/Documents/RichardsonLab/ET-PD project';
    datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
    datadir = '/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings';
    figDir = '~pwjones/Documents/RichardsonLab/SRP/figureDump';
    savedDataDir = '/Volumes/ToughGuy/RichardsonLabData/ET';
    savedDataDir = '~pwjones/Documents/RichardsonLabData/';
end
