function [p,h] = checkElectrodeSignificance(base_ch, signal_ch, zeroi, varargin)
% function results = checkElectrodeSignificance(base_ch, z_amp)

if nargin > 3
    hist_ah = varargin{1};
else
    hist_ah = [];
end

mean_signal = mean(signal_ch((zeroi-600):(zeroi+600),:), 1);
mean_baseline = mean(base_ch,1);

[p, h] = ranksum(mean_signal, mean_baseline);

if ~isempty(hist_ah)
    %let's plot the Z'd data, just so it's more consistent
    s_base = std(mean(base_ch,1));
    mu_base = mean(mean_baseline);
    h1 = histogram(hist_ah, (mean_baseline-mu_base)./s_base, 'Normalization', 'probability');
    hold(hist_ah,'on'); 
    h2 = histogram(hist_ah, (mean_signal-mu_base)./s_base, 'Normalization', 'probability'); 
    h1.BinWidth = .1; h2.BinWidth = .1;
    h1.EdgeColor = 'none';  h2.EdgeColor = 'none'; 
    text(hist_ah, 0, .05, ['p=', num2str(p, 4)]);
end


