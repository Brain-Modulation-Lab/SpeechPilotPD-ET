function pd = linearizePopData(popData)
% function pd = linearizePopData(popData)
%
% De-nests the nested cell arrays in the popData structure
pd = popData;
for ii=1:length(popData)
    di = popData(ii);
    es = []; prevTrials = 0;
    badTrials = []; ntrial = [];
    for jj=1:length(popData(ii).epoch)
        ntrial(jj) = size(popData(ii).epoch{jj},1);
        es = cat(1, es, table2struct(popData(ii).epoch{jj}));
        bt = [popData(ii).badtrial_final{jj}]';
        if ~isempty(bt)
            badTrials = cat(1, badTrials, bt + prevTrials);
        end
        prevTrials = ntrial(jj) + prevTrials;
    end
    pd(ii).badtrial_final = badTrials;
    pd(ii).ntrials = ntrial;
    pd(ii).epoch = struct2table(es);
end
