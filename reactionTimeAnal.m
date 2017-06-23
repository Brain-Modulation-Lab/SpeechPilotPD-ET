% Reaction Times 
setDirectories


for ii = 1:length(Results)
    phys = Results(ii).Onset;
    subjName = strtok(Results(ii).Session, '_');
    data = load([datadir filesep subjName filesep Results(ii).Session]);
    
    dataTime = -phys.parameters{2}:data.nfs
end