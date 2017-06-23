% Reaction Times 
setDirectories


for ii = 1:length(Results)
    rts = Results.Onset
    subjName = strtok(Results(ii).Session, '_');
    data = load([datadir filesep subjName filesep Results(ii).Session]);
end