% Go through population data and look at response times
pb=1;
speechLatencies = NaN*zeros(length(Results), 60);
trialsUsed = cell(length(Results));

for ii=1:length(Results)
    tr = Results(ii).Cue.parameters{10};
    lat = reshape(Results(ii).trials.SpOnset(tr),[],1) - reshape(Results(ii).trials.CommandStim(tr),[],1); 
    trialsUsed{ii} = tr;
    speechLatencies(ii,1:length(tr)) = lat;
end

if pb %plot stuff!
   figure;
   boxplot(speechLatencies', 'plotstyle', 'compact');
end