function [ah, surfh] = plotSpect(x, f, Z, ah)
% function ah = plotSpect(x,f, Z)
%
% Just mainly a wrapper for pcolor, but will plot the spectrogram, taking
% out the lines in order to be less of a pain in the butt.
% Inputs: x - the x values, f - frequencies along the y axis, Z - 2D values

if nargin < 4
    figure; 
    ah = axes;
end

surfh = pcolor(ah, x, f, Z);
shading interp; colormap jet;

