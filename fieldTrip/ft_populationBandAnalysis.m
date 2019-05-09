% Script that assembles the band-passed data across freqencies, locations

setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
freq={'hgamma','broadbandGamma','gamma','hgamma','beta1','beta2','delta','theta','alpha'};
locs = {'Precentral Gyrus',  'Postcentral Gyrus',  'Superior Temporal Gyrus'};
dd = [savedDataDir filesep 'population'];

for gg=1:2
    for ff=1:length(freq)
        %load([dd filesep 'Pop_ecog_' groups{gg} '_' freq{ff} '.mat']);
        for ll=1:length(locs)
            if strcmp(freq{ff}, 'hgamma') %Include in analysis based on hgamma response
                gammasig = arrayfun(@(x) x.sig_h, popData,'UniformOutput', 0);
            end
            locmatch = arrayfun(@(x) strcmpi(x.electrodeLoc, locs{ll}), popData, 'UniformOutput', 0);
            include =  cellfun(@(x,y) x & y, gammasig, locmatch, 'UniformOutput', 0);
            %include = locmatch && gammasig;
            sessionZ = arrayfun(@(x,y) x.meanz(:,y{1}), popData, include, 'UniformOutput', 0);
        end
    end
end
