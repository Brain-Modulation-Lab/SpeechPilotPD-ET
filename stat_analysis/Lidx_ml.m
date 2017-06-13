function lin_idx = Lidx_ml( J, M )%#codegen
%LIDX_ML converts an array of indices J for a multidimensional array M to
%linear indices, directly useable on M
%
% INPUT
%   J       NxP matrix containing P sets of N indices
%   M       A example matrix, with same size as on which the indices in J
%           will be applicable.
%
% OUTPUT
%   lin_idx Px1 array of linear indices
%
% Adapted from Gunther Struyf and gnovice on stackoverflow:
% <http://stackoverflow.com/questions/10146082/indexing-of-unknown-dimensional-matrix>

% method 1
% lin_idx = zeros(size(J,2),1);
% for ii = 1:size(J,2)
%    cellJ = num2cell(J(:,ii)); 
%    lin_idx(ii) = sub2ind(size(M),cellJ{:}); 
% end

% method 2
sizeM = size(M);
if size(J,1)==1
    J(2,:)=1;
end
% lin_idx = cumprod([1 sizeM(1:end-1)]) * (J(:) - [0; ones(numel(J)-1, 1)]);
J(2:end,:) = J(2:end,:)-1;
lin_idx = cumprod([1 sizeM(1:end-1)])*J;
end
