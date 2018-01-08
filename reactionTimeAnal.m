% Reaction Times 
setDirectories;

for ii = 1:length(Results)
    subjName = strtok(Results(ii).Session, '_');
    trialsUsed = Results(ii).Onset.parameters{10};
    spLatency = Results(ii).trials.SpOnset(trialsUsed) - Results(ii).trials.CommandStim(trialsUsed);
    
end