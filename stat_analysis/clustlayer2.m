function [CLU,J]=clustlayer2(C,NE)
% [CLU,NUMC]=CLUSTLAYER2(C,NE) groups all of the observations in C into
% clusters based on the neighbors identified in NE. Note that diagonal
% neighbors (observations that are neighbors along all dimensions but do
% not share the same value in any dimension) are not considered neighbors.
%   C is an M-by-N vector whose rows contain M observations and whose
%       columns contain the indices of the observation along N dimensions.
%   NE is a cell array of logical square matrices where a true value at
%       NE{i}(j,k) indicates that the indices j and k in the ith column of
%       C are neighbors. All diagonal elements of NE must be true.
%   CLU is an M-by-N+1 vector containing the values in C sorted by cluster,
%       where the N+1th column of CLU contains the cluster number for each
%       observation.
%   NUMC is the number of clusters identified by CLUSTLAYER2.
%
%   See also: PERMTESTND, FIND_NEIGHBOR, CLUSTERT, ISMEMBER, INTERSECT, SETDIFF

% zfj, 04/08/15

lastt=1;
prevt=1;
CLU=[];
J=0;
while ~isempty(C) % iterate until all points are assigned to clusters
    if numel(lastt)==numel(prevt);
        J=J+1; % increment cluster number by 1
        lastt=find(ismember(C(:,1),find(NE{1}(C(1,1),:)))); % find neighbors in 1st dimension to first point among pool
        for i=2:size(C,2)
            lastt=intersect(lastt,find(ismember(C(:,i),find(NE{i}(C(1,i),:))))); % find neighbors in ith dimension to first point among pool and collect if neighbors in all dimensions
        end
        if size(C,2)>1
            %Potential error:
            %ign=find(~any(ismember(C(lastt,:),C(1,:)),2)); % label points for deletion which do not share an index with the first cluster along any dimension
            ign=lastt(~any(ismember(C(lastt,:),C(1,:)),2))'; % label points for deletion which do not share an index with the first cluster along any dimension
            
            
            %ign=[];  % don't delete any points if you want to keep "diagonal" neighbors
        else
            ign=[];
        end
        % Potential error:
        lastt(ismember(lastt,ign))=[]; % remove all ignored points from cluster
        %     lastt(ign)=[]; % remove all ignored points from cluster
        prevt=1;
    end
    while numel(lastt)~=numel(prevt) % compare previous points to current points
        prevt=lastt; % store current points as previous points
        lastt=find(ismember(C(:,1),find(any(NE{1}(C(prevt,1),:),1)))); % find neighbors in 1st dimension to previous point among pool
        for i=2:size(C,2)
            lastt=intersect(lastt,find(ismember(C(:,i),find(any(NE{i}(C(prevt,i),:),1))))); % find neighbors in ith dimension to previous points among pool and collect all points which are neighbors to previous points in all dimensions
        end
        if size(C,2)>1
            checkt=setdiff(lastt(~ismember(lastt,ign)),prevt); % collect all newly added points that haven't been labelled for ignore
            for k=1:numel(checkt)
                poss=[];
                for i=1:size(C,2)
                    poss=cat(2,poss,find(ismember(C(prevt,i),C(checkt(k),i)))'); % find old points that have the same index as the new point along any dimension (required to be neighbor)
                end
                poss=unique(poss);
                mem=[];
                if ~isempty(poss) % if there are possible neighbors...
                    for i=1:size(C,2)
                        mem=cat(2,mem,ismember(C(prevt(poss),i),find(NE{i}(C(checkt(k),i),:)))); % check if possible neighbors are neighbors along each dimension
                        
                    end
                end
                if ~any(sum(mem,2)==size(C,2)) % NOT(point is a neighbor along every dimension and shares at least one index in common with at least one point)
                    % % % %                     %add point to cluster, clear ignored points (might be neighbors to new point), exit loop
                    % % % %                     pfound=cat(2,pfound,k);
                    % % % %                     %ign=[]; % ignored points might now be possible neighbors to added point
                    % % % %                 %else
                    ign=cat(2,ign,checkt(k)); % label point for ignore
                end
            end
            lastt(ismember(lastt,ign))=[]; % remove all ignored points from the cluster
        end
    end % if there were new points added, go back to check for neighbors of those points among pool
    
    
    lastign=[];
    while numel(lastign)~=numel(ign) %previously ignored points may have become neighbors
        lastign=ign;
        checki=[];
        for i=1:size(C,2)
            checki=cat(2,checki,find(ismember(C(ign,i),C(lastt,i)))'); %check if any ignored points share an index with any clustered points
        end
        checki=ign(unique(checki));
        
        for k=1:numel(checki) %check if the shared indices occur at neighboring points
            poss=[];
            for i=1:size(C,2)
                poss=cat(2,poss,find(ismember(C(lastt,i),C(checki(k),i)))'); % find old points that have the same index as the new point along any dimension (required to be neighbor)
            end
            poss=unique(poss);
            mem=[];
            for i=1:size(C,2)
                mem=cat(2,mem,ismember(C(lastt(poss),i),find(NE{i}(C(checki(k),i),:)))); % check if possible neighbors are neighbors along each dimension
            end
            if any(sum(mem,2)==size(C,2)) % (point is a neighbor along every dimension and shares at least one index in common with at least one point)
                lastt=cat(1,lastt,checki(k));
            end
        end
        ign(ismember(ign,lastt))=[];
    end
    if numel(lastt)==numel(prevt)
        prevt=sort(prevt);
        CLU=cat(1,CLU,[C(prevt,:) J*ones(numel(prevt),1)]); % put points in new cluster
        C(prevt,:)=[]; % remove points from pool
    end
end
end