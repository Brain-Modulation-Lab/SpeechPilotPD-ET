function out = nancheck(in)

if ~isempty(in)
    out = double(in);
else
    out = NaN;
end
