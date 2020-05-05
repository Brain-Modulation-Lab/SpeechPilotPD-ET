function electrodesBySession = uniqueElectrodes(popData)

electrodesBySession = cell(length(popData),1);
ecount = 0;
subj = unique({popData.subject});
for ii=1:length(subj)
    subj_sessions  = find(strcmp({popData.subject}, subj{ii}));
    prevPos = []; prevNums = [];
    for jj = 1:length(subj_sessions)
        si = subj_sessions(jj);
        enums = 1:length(popData(si).electrodeInfo.label);
        newPos = popData(si).electrodeInfo.native_coord;
        if isempty(prevPos)
            new = 1;
        else
            if (size(newPos,1) == size(prevPos,1) && sum(sum(newPos == prevPos)))
                new = 0;
            else
                new = 1;
            end
        end
        if new
            ei = ecount+enums;
            ecount = max(ei);
        else 
            ei = prevNums;
        end    
        electrodesBySession{si} = ei;
        prevNums = ei;
        prevPos = newPos;
    end
end
            