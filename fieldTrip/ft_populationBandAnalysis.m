% Script that assembles the band-passed data across freqencies, locations

setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
%freqs={'hgamma','broadbandGamma','gamma','hgamma','beta1','beta2','delta','theta','alpha'};
freqs={'hgamma','gamma','beta1','beta2','delta','theta','alpha'};
%freqs={'hgamma','beta1', 'beta2'};
locs = {'M1', 'S1', 'STG'};
dd = [savedDataDir filesep 'population'];
poolSessions = 1;
alignOnset = 0;

if poolSessions
    poolTag = '_pooledSessions';
else
    poolTag = '';
end
if ~alignOnset
    alignTag = '_alignCue';
else
    alignTag = '_alignOnset';
end

for gg=1:2
    clear freq; %this is the population data structure
    for ff=1:length(freqs)
        disp(['Processing ' freqs{ff}]);
        dname = [dd filesep 'Pop_ecog_' groups{gg} '_' freqs{ff} alignTag poolTag '.mat'];
        load(dname);
        disp(['Loading ' dname]);
        %get the speech timing means
        if poolSessions
            popData = linearizePopData(popData);
        end
        for ll=1:length(locs)
            if strcmp(freqs{ff}, 'hgamma') %Include in analysis based on hgamma response
                %gammasig = arrayfun(@(x) x.sig_h', popData,'UniformOutput', 0);
                gammasig = arrayfun(@(x) max(x.clusterT_h',[],2,'omitnan'), popData,'UniformOutput', 0);
            end
            locmatch = arrayfun(@(x) strcmpi(x.electrodeLoc, locs{ll}), popData, 'UniformOutput', 0);
            include =  cellfun(@(x,y) x & y, gammasig, locmatch, 'UniformOutput', 0);
            include_session = cellfun(@(x) sum(x)>0, include); %Are any electrodes from session included
            perSessionZ = cell2mat(arrayfun(@(x,y) x.meanz(:,y{1}), popData, include, 'UniformOutput', 0));
            clusterTp = cell2mat(arrayfun(@(x,y) x.clusterT_p(:,y{1}), popData, include, 'UniformOutput', 0));
            clusterTh = cell2mat(arrayfun(@(x,y) x.clusterT_h(:,y{1}), popData, include, 'UniformOutput', 0));
            clusterTt = reshape([popData(include_session).clusterT_t]',2,[])';
            if size(clusterTh,1) < 2000
                disp('This data file is not updated');
            end
            
            e_cell = {popData(include_session).epoch};
            bad_trial_cell = {popData(include_session).badtrial_final};
            used_trial_cell = cellfun(@(x,y) setdiff(1:size(x,1), y), e_cell, bad_trial_cell, 'UniformOutput', 0);
            stim_timing = cellfun(@(x,y) mean(x.stimulus_starts(y) - x.onset_word(y)), e_cell, used_trial_cell);
            offset_timing = cellfun(@(x,y) mean(x.offset_word(y) - x.onset_word(y)), e_cell, used_trial_cell);
    
            loc(ll).perSessionZ = perSessionZ;
            loc(ll).clusterTp = clusterTp;
            loc(ll).clusterTh = clusterTh;
            loc(ll).clusterTt = clusterTt;
            loc(ll).time = popData(1).time;
            loc(ll).mean_stimOnset = mean(stim_timing);
            loc(ll).mean_speechOffset = mean(offset_timing);
            loc(ll).include = include;  
        end
        freq(ff).loc = loc;
    end
    eval(['summaryData.' groups{gg} '.freq=freq;']);
    summaryData.freq_labels = freqs;
    summaryData.loc_labels = locs;
end

save(fullfile(savedDataDir, 'population', ['summaryData_EcoG_BandAnalysis' alignTag poolTag '.mat']), 'summaryData', '-v7.3');
