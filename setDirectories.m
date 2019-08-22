% Just setup the directories for data, etc
if ispc
    docDir = '\\172.17.146.130\Nexus\Users\pwjones\docs\ET-PD project';
    codeDir = '\\172.17.146.130\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\172.17.146.130\Nexus\DBS';
    subjProcessedDir = 'Preprocessed Data\FieldTrip\further_processed';
    figDir = '\\172.17.146.130\Nexus\Users\pwjones\figureDump';
    savedDataDir = '\\172.17.146.130\Nexus\Users\pwjones\data';
else
    codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';
    docDir = '~pwjones/Documents/RichardsonLab/ET-PD project';
    %datadir = '/Volumes/ToughGuy/RichardsonLabData/ET'; %sample data
    datadir = '/Volumes/Nexus/DBS';
    subjProcessedDir = 'Preprocessed Data/FieldTrip/further_processed';
    figDir = '~pwjones/Documents/RichardsonLab/SRP/figureDump';
    %savedDataDir = '/Volumes/ToughGuy/RichardsonLabData/ET';
    %savedDataDir = '~pwjones/Documents/RichardsonLabData/';
    savedDataDir = '/Volumes/Nexus/Users/pwjones/data';
end
