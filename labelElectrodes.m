function labelList = labelElectrodes(incStr)
%function labelList = labelElectrodes(includeStruct)
%
% incStr is something like sd.PD.freq(1).loc(1).include
labelList = {};
for ii = 1:length(incStr)
    inc = incStr{ii};
    electNum = find(inc);
    for jj=1:length(electNum)
        labelList = cat(1, labelList, ['S' num2str(ii) 'E' num2str(electNum(jj))]); 
    end  
end

