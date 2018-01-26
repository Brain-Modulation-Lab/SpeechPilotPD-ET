% Plots the single trial gamma activity, behavioral correlation data

groups = {'ET', 'PD'};
gc = {[0 0 1], [1 0 0]};
setDirectories;
subjectLists;
locations = {'Precentral Gyrus', 'Postcentral Gyrus', 'Superior Temporal Gyrus'};

fh = figure; ah=[];
for gg = 1:length(groups)
    load([savedDataDir filesep groups{gg} '_SingleTrialActivity.mat'], 'Results');
    setDirectories;
    disp([groups{gg} ' Patients']);
    for ll = 1:length(locations)
        ah(ll) = subplot(2,2, ll);
        loci = find(strcmpi(locations{ll}, {Results.Locations}));
        locResults = Results(loci);
        sigC = [locResults.pvalCspearman] < 0.05;
        sigS = [locResults.pvalSspearman] < 0.05;
        either = sigC | sigS;
        plot([Results(loci).rhoCspearman], [Results(loci)rhoSspearman],'o', 'Color', gc{gg});
        disp(locations{ll});
        medCR = cellfun(@nanmedian, {locResults(sigC).CR});
        medSPR = cellfun(@(x) nanmedian(double(x)), {locResults(sigS).SPR});
        fprintf('%d Electrode-Sessions significantly CueR-RT correlated. Median time %f\n', sum(sigC), mean(medCR));
        fprintf('%d Electrode-Sessions significantly SpeechR-RT correlated. Median time %f\n', sum(sigS), mean(medSPR));
        
        hold on;
        xlabel('\rho Activation w/ Cue');
        ylabel('\rho Activation w/ Speech Onset');
        title(locations{ll});
    end
end



% Come up with count for electrodes
subjects = [];
for gg=1:length(groups)
    load([savedDataDir filesep groups{gg} '_SingleTrialActivity.mat'], 'Results');
    for ll = 1:length(locations)
        n = 0;
        eval(['subjects=' groups{gg} '_subjects;']);
        for ss = 1:length(subjects)
            subi = find(strncmp(subjects{ss}, {Results.Session}, 7));
            chans = [Results(subi).Channel];
            locs = {Results(subi).Locations};
            [c, ia] = unique(chans);
            locmatch = strcmpi(locations{ll}, locs(ia));
            n = sum(locmatch) + n;
        end
        fprintf('In %s group: %d electrodes in %s\n', groups{gg}, n, locations{ll});
    end
end