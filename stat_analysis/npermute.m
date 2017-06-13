function [NEWA,NEWB,K]=npermute(N,A,B,ISPAIRED)
% [NEWA,NEWB,K]=NPERMUTE(N,A,B,ISPAIRED) shuffles the values in A and B
% along the Nth dimension, returning two matrices of the same size but with
% different sets of values.
%   K is the random permutation vector used to assemble NEWA and NEWB.
%   If ISPAIRED is true, then the data in A and B are parcelled such that
%       the ith index of A in the Nth dimension can only be swapped with
%       the ith index of B in the Nth dimension. If M is the size of A and
%       B along the Nth dimension, then K is a 1-by-M vector of with
%       possible values 1 and 2. When K==1, the values of A along that
%       index are assigned to NEWA and the values of B along that index are
%       assigned to NEWB. When K==2, the values of A along that index are
%       assigned to NEWB and the values of B along that index are assigned
%       to NEWA.
%   If ISPAIRED is false, then the data in A and B are parcelled
%       irrespective of index in the Nth dimension. If M is the size of A
%       and B along the Nth dimension, then K takes on values of 1:2*M,
%       with 1:M corresponding to the indices of A in the Nth dimension and
%       M+1:2*M corresponding to the indices of B in the Nth dimension. The
%       first M values in K are then assigned to NEWA and the remaining M
%       values are assigned to NEWB and the data from the corresponding
%       subsets of A and B are parcelled accordingly.
%
%   See also: PERMTESTND

%   zfj, 04/08/15

if ISPAIRED
    A = shiftdim(A,N-1); % make dimension of interest first dimension
    B = shiftdim(B,N-1); % make dimension of interest first dimension
    K = randi(2,size(A,1),1); % create random permutation
    NEWA = shiftdim(reshape(cat(1,A(K==1,:),B(K==2,:)),size(A)),1); % permute matrix along dimension of interest, reshape and shift back to original size
    NEWB = shiftdim(reshape(cat(1,B(K==1,:),A(K==2,:)),size(A)),1); % permute matrix along dimension of interest, reshape and shift back to original size
else
    J = shiftdim(cat(N,A,B),N-1); % concatenate along dimension of interest and make it the first dimension
    K = randperm(size(J,1)); % create random permutation
    J = J(K,:); % permute matrix
    ra = size(shiftdim(A,N-1)); % get size of first half of J
    rb = size(shiftdim(B,N-1)); % get size of second half of J
    NEWA = shiftdim(reshape(J(1:size(A,N),:),ra),1); % take first half of J, reshape to original size
    NEWB = shiftdim(reshape(J((size(A,N)+1):end,:),rb),1); % take second half of J, reshape to original size
end

end