function out = extractTrialNum(in)

if ~isnan(in)
    out = cell2mat(textscan(in, 'trial%f'));
else
    out = 0;
end
