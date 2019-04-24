%Cycle through and collect information about electrode locations and
%whether or not they were previously marked bad. Function written to
%utilize all of the manual preprocessing done on screening data before 
%FieldTrip switch, but need to convert all used data to fieldTrip analysis 
%for consistency w/ rest of lab.

setDirectories; %platform specific locations 
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
subjectLists; %load lists of subjects
subjects = ET_subjects;
group = 'ET';

sessionN = 1;
electrodeInfo = [];
for s=1:length(subjects)
    tmp=dir([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep 'DBS*.mat']);
    
    for fi=1:length(tmp)
        clear locLabels;
        data=load([datadir filesep subjects{s} filesep 'Preprocessed Data' filesep tmp(fi).name],'Ecog','trials','nfs', 'badch','labels', 'EcogLabels','Side', 'SubjectID', 'wordlist');
        if isfield(data, 'EcogLabels') data.labels = data.EcogLabels; end
        disp(['Loaded data from ' tmp(fi).name]);
        
        electrodeLocs = readElectrodeLocXLS(electrodeFile, group); %need to read in a match to the anatomically localized
        ematch = find(strcmp(data.SubjectID, {electrodeLocs.subject}) & strcmpi(data.Side, {electrodeLocs.side}));
        for ii = 1:length(ematch) % There can be multiple strips per recording
            locLabels(cell2mat({electrodeLocs(ematch(ii)).channels})) = electrodeLocs(ematch(ii)).labels;
        end
        
        chUsed = setdiff(1:size(data.Ecog,2), data.badch); %select the good channels
        %get a session number
        [~,remain] = strtok(tmp(fi).name, '_'); [sessionName,remain] = strtok(remain, '_');
        sessionNum = sscanf(sessionName, '%*7c%d');
        
        %save the data and labels
        electrodeInfo(sessionN).subjectID = data.SubjectID;
        
        electrodeInfo(sessionN).side = data.Side;
        electrodeInfo(sessionN).electrodeID = data.labels;
        electrodeInfo(sessionN).electrodeLoc = locLabels;
        electrodeInfo(sessionN).badch = data.badch;
        electrodeInfo(sessionN).usedChannels = chUsed;
        electrodeInfo(sessionN).session = sessionNum;
        sessionN = sessionN + 1;
        
    end
end

save([savedDataDir filesep 'population' filesep group '_electrodeInfo.mat'], 'electrodeInfo');