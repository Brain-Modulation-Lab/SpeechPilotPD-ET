function S=permtestND(A,B,D,DT,AT,AS,REPS,ISPAIRED,ne)
% S=PERMTESTND(A,B,D,DT,AT,AS,REPS,ISPAIRED) performs a cluster-based 
% permutation test on the data in A and B along the last dimension. Each
% cluster is identified cross-referencing a t-test between A and B along
% the last dimension with the positional information in D and DT. Each
% cluster is assigned a t-statistic by summing the t-statistics of each
% observation in A and B which belong to that cluster. Clusters are then
% tested against randomly permuted data to determine significance.
%   D is a cell array of Ni-by-Mi matrices, where Ni is the number of
%       points in the ith dimension of a dataset and Mi is the number of
%       dimensions that define the relationship between points. Each row j
%       in D{i} corresponds to the coordinates of the jth point in the
%       subspace of that dimension.
%   DT is a vector of distances beyond which the points in D are not
%       considered neighbors. Each DT(i) corresponds to the threshold
%       distance for D{i}.
%   AT is the threshold t-statistic which individual observations must
%       surpass in order to be considered for clustering. The value of AT
%       does not affect the false alarm rate of the permutation test, only
%       its sensitivity.
%   AS defines the significance level of the test. Clusters are only
%       signicant if their summed t-statistics are greater than AS*REPS
%       values in MT. The significance level for the permutation test is
%       thus p<(1-AS).
%   REPS is the number of random permutations to perform on the data in A
%       and B. The confidence interval of the test is very large for small
%       values of REPS and narrows asymptotically as REPS becomes
%       increasingly large.
%   If ISPAIRED is true, then the observations in each index of A and B are
%       considered paired values and the permutation test is run using
%       paired t-tests and by permuting between paired values of A and B
%       only. If ISPAIRED is false, then two-sample t-tests are run and all
%       observations in A and B are permuted.
%
%   S is a structure with the following fields:
%       S.sigc  :   A matrix of significant clusters where each row
%                   corresponds to an observation in A and B, the last
%                   column corresponds to the cluster number, and the
%                   preceding columns correspond to the indices of the
%                   observations in A and B along their respective
%                   dimensions
%       S.sigt  :   A vector of the t-statistics for each cluster in S.sigc
%       S.sigp  :   A vector of the p-values for each cluster in S.sigc
%       S.mt    :   A vector of the largest t-statistics from each
%                   permutation of the permutation test, used to test for
%                   significant clusters
%
%   See also: FIND_NEIGHBOR, NPERMUTE, CLUSTERT, CLUSTLAYER2, PERMUTE_SIG
%

% zfj, 04/09/15

fprintf('Performing Permutation Test:\n');
sizstr=strjoin(cellfun(@num2str, num2cell(size(squeeze(A))),'un',0),'x');
if ISPAIRED
    pairstr='Paired';
else
    pairstr='Two-sample';
end
fprintf('\tData size:\t\t%s\n\tT-statistic:\t\t%s\n',sizstr(1:end-2),pairstr);
clear sizst pairstr
fprintf('Looking for clusters...\n');

if ~exist('ne','var')
    ne = find_neighbor(D,DT);
end
clear D DT;

[~,expc,expt]=clustert(A,B,AT,ne,ISPAIRED); %%% play with order for speed
if numel(expt)==0
    error('Sensitivity level too high. No clusters were identified. Please select a lower t-value.')
else
    fprintf('%d cluster(s) identified.\n',numel(expt));
end
% mt=zeros(1,REPS);
% % fprintf('Permutation:  of %d\n',REPS);
% fprintf('Permuting...');
% parfor_progress(REPS);
% parfor r = 1:REPS
% %     fprintf('%s%d of %d',sprintf(repmat('\b',1,numel(num2str(r-1))+4+numel(num2str(REPS)))),r,REPS);
%     [newa,newb] = npermute(ndims(A),A,B,ISPAIRED);
%     mt(r) = clustert(newa,newb,AT,ne,ISPAIRED);
%     parfor_progress;
% end
% parfor_progress(0);
% fprintf('\n');
% S = permute_sig(mt,expt,AS,expc);

mt=zeros(REPS,2);
% fprintf('Permutation:  of %d\n',REPS);
fprintf('Permuting...');
parfor_progress(REPS);
for r = 1:REPS
%     fprintf('%s%d of %d',sprintf(repmat('\b',1,numel(num2str(r-1))+4+numel(num2str(REPS)))),r,REPS);
    [newa,newb] = npermute(ndims(A),A,B,ISPAIRED);
    mt(r,:) = clustert2(newa,newb,AT,ne,ISPAIRED);
    parfor_progress;
end
parfor_progress(0);
fprintf('\n');
S = permute_sig2(mt,expt,AS,expc);

end



