% Plots the single trial, behavioral correlation data

groups = {'ET', 'PD'};
gc = {[0 0 1], [1 0 0]};
setDirectories;
locations = {'Precentral Gyrus', 'Postcentral Gyrus', 'Superior Temporal Gyrus'};

fh = figure;
for gg = 1:length(groups)
    load([savedDataDir filesep groups{gg} '_SingleTrialActivity.mat']);
    for ll = 1:length(locations)
        ah(ll) = subplot(2,2, ll);
        loci = find(strcompi(locations{ll}, [Results.chan.Locations]));
        title(locations{ll});
    end
end
