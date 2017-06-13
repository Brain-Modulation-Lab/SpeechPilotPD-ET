function S=permute_sig2(MT,EXPT,AS,EXPC)
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
MT=MT(:);
S.mt=sort(MT);
sigtp = EXPT(EXPT>S.mt(ceil(AS*numel(MT)))); % find clusters that are significant to p<(1-AS)
sigcp = EXPC(ismember(EXPC(:,end),find(ismember(EXPT,sigtp))),:); % find clusters that are significant to p<(1-AS)

sigpp = ones(size(sigtp));
c = unique(sigcp(:,end));
for s = 1:length(c)
    sigcp(sigcp(:,end)==c(s),end)=s; % convert cluster numbers to sequential integers starting with 1
    sigpp(s)=sum(S.mt>sigtp(s))/numel(MT); % calculate p-value for each cluster
end
sp=size(sigtp,1);
sigtn = EXPT(EXPT<S.mt(floor((1-AS)*numel(MT)))); % find clusters that are significant to p<(1-AS)
sigcn = EXPC(ismember(EXPC(:,end),find(ismember(EXPT,sigtn))),:); % find clusters that are significant to p<(1-AS)
clear AS EXPC EXPT

sigpn = ones(size(sigtn));
c = unique(sigcn(:,end));
for s = 1:length(c)
    sigcn(sigcn(:,end)==c(s),end)=s+sp; % convert cluster numbers to sequential integers starting with 1
    sigpn(s)=sum(S.mt<sigtn(s))/numel(MT); % calculate p-value for each cluster
end
S.sigt=[sigtp; sigtn];
S.sigc=[sigcp; sigcn];
S.sigp=[sigpp; sigpn];
S = orderfields(S,{'sigc','sigt','sigp','mt'});
fprintf('%d significant cluster(s) found.\n',numel(S.sigt));
end