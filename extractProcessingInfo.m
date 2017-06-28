% Let's try to extract the parameter fields from the huge data file

fn = 'Band_modulation_referenced_PD3_v2.mat';
fileO = matfile(fn);

nSession = length(fileO.Results);
for ii = 1:nSession
   params = fileO.Results(ii).Onset.parameters;
   sessionInfo(ii).params = params;
end