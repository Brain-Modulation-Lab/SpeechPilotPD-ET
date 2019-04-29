% Just setup the directories for data, etc
if ispc
    docDir = '\\136.142.16.9\Nexus\Users\pwjones\docs\ET-PD project';
    codeDir = '\\136.142.16.9\Nexus\Users\pwjones\code\SpeechPilotPD-ET';
    datadir='\\136.142.16.9\Nexus\DBS';
    subjProcessedDir = 'Preprocessed Data\FieldTrip\further_processed';
    figDir = '\\136.142.16.9\Nexus\Users\pwjones\figureDump';
    savedDataDir = '\\136.142.16.9\Nexus\Users\pwjones\data';
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
