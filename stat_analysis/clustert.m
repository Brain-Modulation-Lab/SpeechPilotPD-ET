function [MT,CLU,CLUT]=clustert(A,B,AT,NE,ISPAIRED)
% [MT,CLU,CLUT]=CLUSTERT(A,B,AT,NE) computes a t-statistic for each
% observation in A vs. B along the last dimension and returns the clusters
% of observations that surpass a threshold t-statistic AT.
%   NE is a cell array of logical square matrices where a true value at
%       NE{i}(j,k) indicates that the indices j and k in the ith dimension
%       of A and B are neighbors. All diagonal elements of NE must be true.
%   If ISPAIRED is true, then a paired t-test is run. If ISPAIRED is false,
%       then a two-sample t-test is run instead.
%   MT is the maximum t-statistic among the clusters identified by
%       clustlayer2. Cluster t-statistics are computed as the sum of each
%       component t-statistic.
%   CLU is an N-by-M matrix where N is the number of clusters identified
%       and M the number of dimensions of A and B. The first through
%       (M-1)th columns of CLU correspond to the indices of the observation
%       along the first M-1 dimensions, respectively, of A and B. The Mth
%       column of CLU is the cluster number to which the observation
%       belongs. The rows of CLU are sorted by column in descending order
%       (M, then M-1, then... , then 1).
%   CLUT is a column vector of t-statistics for each cluster identified by
%       CLUSTERT.
%
%   See also: PERMTESTND, FIND_NEIGHBOR, CLUSTLAYER2, LIDX_ML, NTHOUT, TTEST, TTEST2
 
% zfj1, 04/08/15

if ISPAIRED
    ts = getfield(nthout(4,@ttest,A,B,'Dim',ndims(A)),'tstat'); % calculate paired t-statistics
else
    ts = getfield(nthout(4,@ttest2,A,B,'Dim',ndims(A)),'tstat'); % calculate two-sample t-statistics
end
if size(A,1)==size(A,2)
ts=triu(ts,1);
end
D = size(A);
[pclu{1:numel(D)-1}] = ind2sub(D(1:end-1),find(ts>AT)); %find N-D subscripts of positive critical indices
[pclu,pnumc] = clustlayer2(cat(2,pclu{:}),NE); % find clusters
pclut=zeros(pnumc,1); 
for n=1:pnumc
    pclut(n)=sum(ts(Lidx_ml(pclu(pclu(:,end)==n,1:end-1)',ts))); % sum t-statistics for each cluster
end

[nclu{1:numel(D)-1}] = ind2sub(D(1:end-1),find(ts<-AT)); %find N-D subscripts of negative critical indices
[nclu,nnumc] = clustlayer2(cat(2,nclu{:}),NE); % find clusters
nclut=zeros(nnumc,1);
for n=1:nnumc
    nclut(n)=sum(ts(Lidx_ml(nclu(nclu(:,end)==n,1:end-1)',ts))); % sum t-statistics for each cluster
end
if ~isempty(nclu)
    nclu(:,end)=nclu(:,end)+pnumc; % negative clusters begin where positive clusters end
end
CLU=cat(1,pclu,nclu);
CLUT=cat(1,pclut,nclut);
MT=max(abs(CLUT));
if isempty(MT)
    MT=0;
end
end