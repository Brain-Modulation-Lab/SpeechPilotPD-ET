% Script that assembles the band-passed data across freqencies, locations

setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
freq={'broadbandGamma','gamma','hgamma','beta1','beta2','delta','theta','alpha'};
locs = {'Precentral Gyrus',  'Postcentral Gyrus',  'Superior Temporal Gyrus'};

for ff=1:length(freq)
    for ll=1:length(locs)
        if strcmp(freq, 'hgamma')
            gammasig = arrayfun(@(x) x.sig_h, popData,'UniformOutput', 0); 
        end
        locmatch = arrayfun(@(x) strcmpi(x.electrodeLoc, locs{ll}), popData, 'UniformOutput', 0); 
        include =  cellfun(@(x,y) x & y, gammasig, locmatch, 'UniformOutput', 0); 
        %include = locmatch && gammasig;
        sessionZ = arrayfun(@(x,y) x.meanz(:,y{1}), popData, include, 'UniformOutput', 0);
    end
end
