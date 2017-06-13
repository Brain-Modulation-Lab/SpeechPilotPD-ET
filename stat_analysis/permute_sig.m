function S=permute_sig(MT,EXPT,AS,EXPC)
% S=PERMUTE_SIG(MT,EXPT,AS,EXPC) returns a structure S detailing the
% significant clusters in EXPC based on the significance criterion AS and
% the results, MT, of a permutation test on the data from which the
% clusters are drawn.
%   MT is a vector of the maximum cluster t-statistics obtained from each
%       iteration ofthea permutation test.
%   EXPT is a vector of cluster t-statistics obtained from the true labels
%       in the permutation test.
%   AS defines the significance level of the test. Clusters are only
%       signicant if their t-statistics are greater than AS*numel(MT)
%       values in MT. The significance level for the permutation test is
%       thus p<(1-AS).
%   EXPC is a matrix of cluster indices, created by clustlayer2, obtained
%       from the true labels in the permutation test.
%   S is a structure with the following fields:
%       S.sigc  :   A matrix of significant clusters from EXPC with the
%                   same format and sequential integers from 1 as cluster
%                   numbers
%       S.sigt  :   A vector of the t-statistics for each cluster in S.sigc
%       S.sigp  :   A vector of the p-values for each cluster in S.sigc
%       S.mt    :   The sorted results of the permutation test
%
%   See also: PERMTESTND, CLUSTLAYER2, CLUSTERT,  

% zfj, 04/09/15

S.mt=sort(MT);
S.sigt = EXPT(abs(EXPT)>S.mt(ceil(AS*numel(MT)))); % find clusters that are significant to p<(1-AS)
S.sigc = EXPC(ismember(EXPC(:,end),find(ismember(EXPT,S.sigt))),:); % find clusters that are significant to p<(1-AS)
clear AS EXPC EXPT

S.sigp = ones(size(S.sigt));
c = unique(S.sigc(:,end));
for s = 1:length(c)
    S.sigc(S.sigc(:,end)==c(s),end)=s; % convert cluster numbers to sequential integers starting with 1
    S.sigp(s)=sum(S.mt>abs(S.sigt(s)))/numel(MT); % calculate p-value for each cluster
end

S = orderfields(S,{'sigc','sigt','sigp','mt'});
fprintf('%d significant cluster(s) found.\n',numel(S.sigt));
end