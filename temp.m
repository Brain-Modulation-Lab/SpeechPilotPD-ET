% minT = 0; maxT = 0;
% for ii=1:length(Results)
%     trTime = linspace(-Results(ii).(align).parameters{2}, Results(ii).(align).parameters{4}, size(Results(ii).(align).zsc,2));    
%     minT = min(minT, -Results(ii).(align).parameters{2});
%     maxT = max(maxT, Results(ii).(align).parameters{4});
% end
% dt= mean(diff(trTime));
% popTime = linspace(minT, maxT, (maxT-minT)/dt);
% 

% nsubj = length(Results);
% for ii=1:nsubj
%     trialsUsed = Results(ii).Cue.parameters{10};
%     respTime = Results(ii).trials.SpOnset(trialsUsed) - Results(ii).trials.CommandStim(trialsUsed);
%     respOffset = Results(ii).trials.SpOffset(trialsUsed) - Results(ii).trials.CommandStim(trialsUsed);
%     meanRespTime(ii) = mean(respTime);
%     meanRespOffset(ii) = mean(respOffset);
% end

