function [p,h, signali] = permuteElectrodeSignificance(base_ch, signal_ch, zeroi, varargin)
% function [p,h] = checkElectrodeSignificance(base_ch, signal_ch, zeroi, varargin)
%
% Tests the matrices for baseline versus signal to determine significance. 
% Uses the cluster permutation testing for a trial matrix. 
% Tests the signal zeroi + 1:size(basech,1)
% because we need to be comparing identical lengths of data.
% Inputs: Signal and base matrices are trials in columns, and time is in
% the first dimension down the rows. zeroi is the index to start
% considering the signal.
% Outputs: p-values and significance (h).
basen = size(base_ch,1); 
signali = zeroi + (1:basen);
used_signal = signal_ch(signali,:);

%[p, h] = ranksum(mean_signal, mean_baseline);
[h, p] = clusterPermuteTtest(used_signal', base_ch', .075);
min_p = min(p);
sum_h = sum(h);

