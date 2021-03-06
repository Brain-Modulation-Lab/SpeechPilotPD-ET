% Script that assembles the band-passed data across freqencies, locations
% This version does so per unique electrode position rather than leaving multiple sessions per electrode separate

setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
%freqs={'hgamma','broadbandGamma','gamma','hgamma','beta1','beta2','delta','theta','alpha'};
freqs={'hgamma','gamma','beta1','beta2','delta','theta','alpha'};
locs = {'M1', 'S1', 'STG'};
dd = [savedDataDir filesep 'population'];

for gg=1:2
    clear freq; %this is the population data structure
    for ff=1:length(freqs)
        disp(['Processing ' freqs{ff}]);
        load([dd filesep 'Pop_ecog_' groups{gg} '_' freqs{ff} '.mat']);
        for ll=1:length(locs)
            if strcmp(freqs{ff}, 'hgamma') %excuted a couple more times than necessary,ok
                gammasig = arrayfun(@(x) x.sig_h', popData,'UniformOutput', 0); %sig by rank sum
            end
            locmatch = arrayfun(@(x) strcmpi(x.electrodeLoc, locs{ll}), popData, 'UniformOutput', 0);
            include =  cellfun(@(x,y) x & y, gammasig, locmatch, 'UniformOutput', 0);
            include_session = cellfun(@(x) sum(x)>0, include); %Are any electrodes from session included
            perSessionZ = cell2mat(arrayfun(@(x,y) x.meanz(:,y{1}), popData, include, 'UniformOutput', 0));
            %get the speech timing means
            e_cell = {popData.epoch};
            bad_trial_cell = {popData.badtrial_final};
            used_trial_cell = cellfun(@(x,y) setdiff(1:size(x,1), y), e_cell, bad_trial_cell, 'UniformOutput', 0);
            stim_timing = cellfun(@(x,y) x.stimulus_starts(y) - x.onset_word(y), e_cell, used_trial_cell,'UniformOutput', 0);
            offset_timing = cellfun(@(x,y) x.offset_word(y) - x.onset_word(y), e_cell, used_trial_cell,'UniformOutput', 0);
            
            % gonna combine over sessions with the same electrodes
            [electID, sg] = uniqueElectrodes(popData);
            subjectMeanZ = []; subjectStdZ=[]; includedENum = []; 
            stim_timing_subj = {}; offset_timing_subj = {};
            for kk = 1:length(sg)
                tZ = []; st = []; ot = [];
                for jj = 1:length(sg{kk})
                    sess = sg{kk}; %Need to pool over the sessions
                    tZ = cat(2, tZ, popData(sess(jj)).trialzM);
                    st = cat(1, st, stim_timing{sess(jj)});
                    ot = cat(1, ot, offset_timing{sess(jj)});
                end
                mZ = squeeze(nanmean(tZ, 2)); stdZ = squeeze(nanstd(tZ,0,2));
                % include array if ANY of the individual sessions inc
                include_subj{kk} = logical(sum(cell2mat({include{sg{kk}}}),2));
                if (sum(include_subj{kk})) %collapse into matrix by electrode
                    subjectMeanZ = cat(2, subjectMeanZ, mZ(:,include_subj{kk}));
                    subjectStdZ = cat(2, subjectStdZ, stdZ(:,include_subj{kk}));
                    eNum = electID{sg{kk}(1)};
                    includedENum = cat(2, includedENum, eNum(include_subj{kk}));
                end
                stim_timing_subj{kk} = st;
                offset_timing_subj{kk} = ot; 
            end
            loc(ll).meanZ_subj = subjectMeanZ;
            loc(ll).stdZ_subj = subjectStdZ;
            loc(ll).mean_stimOnset_subj = cellfun(@(x) mean(x), stim_timing_subj);
            loc(ll).mean_speechOffset_subj = cellfun(@(x) mean(x), offset_timing_subj);
            loc(ll).include_subj = include_subj; 
            loc(ll).includedENum = includedENum;
            loc(ll).perSessionZ = perSessionZ;
            loc(ll).time = popData(1).time;
            loc(ll).mean_stimOnset = mean(cellfun(@(x) mean(x), stim_timing));
            loc(ll).mean_speechOffset = mean(cellfun(@(x) mean(x), offset_timing));
            loc(ll).include = include;  
        end
        freq(ff).loc = loc;
    end
    eval(['summaryData.' groups{gg} '.freq=freq;']);
    summaryData.freq_labels = freqs;
    summaryData.loc_labels = locs;
end

save(fullfile(savedDataDir, 'population', 'summaryData_EcoG_BandAnalysis.mat'), 'summaryData', '-v7.3');
