function [R,z] =perm_zerom(imgs,stat,tails)

nperm=stat.surrn;
% calculate matrix size
bsize = size(imgs);
nsub = bsize(3);
bsize = bsize(1:2);

% calculate true mean image
truestat = mean(imgs,3)./(std(imgs,0,3)./sqrt(nsub));
implicitmask = ~isnan(truestat);

nvox = sum(implicitmask(:));

% extract occupied voxels for permutation test
occimgs = NaN(nvox,nsub);
for s = 1:nsub
    curimg = imgs(:,:,s);
    occimgs(:,s) = curimg(implicitmask);
end

% initialize progress indicator
parfor_progress(nperm);
% cycle through permutations
surr = zeros(bsize(1),bsize(2),nperm);
parfor(p = 1:nperm)
    % permute signs
    relabeling = randi([0,1],nsub,1);
    roccimgs = occimgs;
    for s = 1:nsub
        if relabeling(s) == 1;
            roccimgs(:,s) = -occimgs(:,s);
        end
    end
    
    % calculate permutation statistic
    rstats =  mean(roccimgs,2)./(std(roccimgs,0,2)./sqrt(nsub));
    rbrain = zeros(bsize);
    rbrain(implicitmask) = rstats;
    surr(:,:,p)=rbrain;
    parfor_progress;
end
parfor_progress(0);
[R, z]=cluster_sigt(truestat,nsub-1,surr,stat,8);
% [R, z]=cluster_sig2(truestat,nsub-1,surr,stat,tails,8);
end