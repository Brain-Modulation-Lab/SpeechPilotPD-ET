function [electrodesBySession, session_groups] = uniqueElectrodes(popData)
% function [electrodesBySession, session_groups] = uniqueElectrodes(popData)
%
% Output: electrodesBySession = cell array of unique electrode IDs per session
%         session_groups = cell array of session IDs with the same
%         electrodes

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

% Make a list of sessions with the same electrodes
session_groups = {}; gn=0; old_en = [];
for ii=1:length(popData)
    if (length(electrodesBySession{ii}) == length(old_en) && sum(electrodesBySession{ii} == old_en)) %electrodes match
        session_groups{gn} = cat(1, session_groups{gn}, ii);
    else
        gn = gn+1;
        session_groups{gn} = ii;
    end
    old_en = electrodesBySession{ii};
end
            