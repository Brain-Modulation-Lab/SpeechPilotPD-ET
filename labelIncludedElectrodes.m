function electrodeLabels = labelIncludedElectrodes(includeCell)
%electrodeLabels = labelIncludedElectrodes(includeCell)
%
% input = includeCell is a cell array of boolean arrays
% output = cell array of strings with 'SXEY' for every boolean that is positive

electrodeLabels = {}; n=1; 
for ss=1:length(includeCell);
    inc = find(includeCell{ss});
    if ~isempty(inc)
        for ii=1:length(inc)
            electrodeLabels{n} = sprintf('S%dE%d', ss, inc(ii));
            n = n+1;
        end
    end
end

