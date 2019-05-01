% Assemble the population level data for the ET vs PD ECoG analysis

%Note: DBS4053 session 2, no electrode info found.  Need to look into that

setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
subjectLists; %lists of subject IDs
fs = 1000; % data sampling frequency

for gg = 1:length(groups)
    df = dir([savedDataDir filesep 'subjects' filesep ids{gg}]);
    
end

