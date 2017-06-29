% Let's try to extract the parameter fields from the huge data file

% fn = 'Band_modulation_referenced_PD3_v2.mat';
% fileO = matfile(fn);

% nSession = length(fileO.Results);
% for ii = 1:nSession
%    res = fileO.Results(1,ii);
%    params = res.Onset.parameters;
%    sessionInfo(ii).params = res.Onset.parameters;
%    sessionInfo(ii).name = res.Session;
% end
% 
% save('PD_sessionInfo', 'sessionInfo');

nSession = length(Results);
for ii = 1:nSession
   res = Results(1,ii);
   params = res.Onset.parameters;
   sessionInfo(ii).params = res.Onset.parameters;
   sessionInfo(ii).name = res.Session;
end

save('ET_sessionInfo', 'sessionInfo');