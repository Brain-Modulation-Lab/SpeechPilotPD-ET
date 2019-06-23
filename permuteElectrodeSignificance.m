function [p,h] = permuteElectrodeSignificance(base_ch, signal_ch, zeroi)
% function [p,h] = checkElectrodeSignificance(base_ch, signal_ch, zeroi, varargin)
%
% Tests the matrices for baseline versus signal to determine significant
% Uses the cluster permutation testing for a trial matrix. 
% Inputs: Signal and base matrices are trials in columns, and time is in
% the first dimension down the rows
% Outputs: p-values and significance (h).
basen = size(base_ch,1); 
offset = floor(basen/2); 
used_signal = signal_ch((zeroi-offset):(zeroi+(basen-offset)-1),:);
mean_baseline = mean(base_ch,1);

%[p, h] = ranksum(mean_signal, mean_baseline);
[h, p] = clusterPermuteTtest(used_signal', base_ch', .075);
min_p = min(p);
sum_h = sum(h);
