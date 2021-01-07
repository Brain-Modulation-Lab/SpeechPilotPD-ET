incE = {}; n=1;
for ff=1:length(sd.PD.freq)
    for ll=1:length(sd.PD.freq(ff).loc)
        for ss=1:length(sd.PD.freq(ff).loc(ll).include)
            inc = find(sd.PD.freq(ff).loc(ll).include{ss});
            if ~isempty(inc)
                for ii=1:length(inc)
                    incE{n} = sprintf('S%dE%d', ss, inc(ii));
                    n = n+1;
                end
            end
        end
    end
end
