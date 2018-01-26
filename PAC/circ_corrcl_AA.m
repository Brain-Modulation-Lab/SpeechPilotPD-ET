function [rho] = circ_corrcl_AA(alpha, a)
%
% [rho pval ts] = circ_corrcc(alpha, x)
%   Correlation coefficient between one circular and one linear random
%   variable.
%
%   Input:
%     alpha   sample of angles in radians
%     x       sample of linear random variable
%     dim     dimension of the trials
%   Output:
%     rho     correlation coefficient
%     pval    p-value
%
% References:
%     Biostatistical Analysis, J. H. Zar, p. 651
%
% PHB 6/7/2008
%
% Circular Statistics Toolbox for Matlab

% By Philipp Berens, 2009
% berens@tuebingen.mpg.de - www.kyb.mpg.de/~berens/circStat.html

% compute correlation coefficent for sin and cos independently

rxs =diag(corr(a,sin(alpha)));
rxc= diag(corr(a,cos(alpha)));
rcs=diag(corr(sin(alpha),cos(alpha)));
% compute angular-linear correlation (equ. 27.47)

rho = sqrt(bsxfun(@rdivide,(bsxfun(@minus,rxc.^2 + rxs.^2, bsxfun(@times,2*rxc.*rxs,rcs))),(1-rcs.^2)));
