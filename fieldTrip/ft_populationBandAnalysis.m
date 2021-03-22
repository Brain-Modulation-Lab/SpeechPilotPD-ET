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
alignOnset = 1;

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
        clear loc;
        for ll=1:length(locs)
            if strcmp(freqs{ff}, 'hgamma') %Include in analysis based on hgamma response
                %gammasig = arrayfun(@(x) x.sig_h', popData,'UniformOutput', 0);
                gammasig = arrayfun(@(x) max(x.clusterT_h',[],2,'omitnan'), popData,'UniformOutput', 0);
            end
            if strcmp(freqs{ff}, 'hgamma') || strcmp(freqs{ff}, 'gamma')
                peakf = @max;
            else
                peakf = @min;
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
            
            electrodeLabel = labelIncludedElectrodes(include);
            e_cell = {popData(include_session).epoch};
            bad_trial_cell = {popData(include_session).badtrial_final};
            used_trial_cell = cellfun(@(x,y) setdiff(1:size(x,1), y), e_cell, bad_trial_cell, 'UniformOutput', 0);
            stim_timing = cellfun(@(x,y) mean(x.stimulus_starts(y) - x.onset_word(y)), e_cell, used_trial_cell);
            offset_timing = cellfun(@(x,y) mean(x.offset_word(y) - x.onset_word(y)), e_cell, used_trial_cell);
            [peak_response, peaki] = peakf(perSessionZ);
            cTt = linspace(clusterTt(1,1), clusterTt(1,2), size(clusterTh,1));
            ft = NaN*ones(size(perSessionZ, 2),1);  lt = ft; peakt=ft;
            for ii=1:size(perSessionZ, 2)
                temp = find(clusterTh(:,ii)>0,1, 'first');
                if ~isempty(temp); ft(ii) = cTt(temp); end
                temp = find(clusterTh(:,ii)>0,1, 'last') ;
                if ~isempty(temp); lt(ii) = cTt(temp); end
                
                peakt(ii) = popData(1).time(peaki(ii));
            end
           
            loc(ll).perSessionZ = perSessionZ;
            loc(ll).clusterTp = clusterTp;
            loc(ll).clusterTh = clusterTh;
            loc(ll).clusterTt = clusterTt;
            loc(ll).time = popData(1).time;
            loc(ll).peakZ = peak_response;
            loc(ll).peakt = peakt;
            loc(ll).firstSigRespT = ft;
            loc(ll).lastSigRespT = lt;
            loc(ll).perSession_stimOnset = stim_timing;
            loc(ll).mean_stimOnset = mean(stim_timing);
            loc(ll).perSession_speechOffset = offset_timing;
            loc(ll).mean_speechOffset = mean(offset_timing);
            loc(ll).include = include; 
            loc(ll).include_session = include_session;
            loc(ll).electrodeLabel = electrodeLabel;
            
        end
        freq(ff).loc = loc;
    end
    eval(['summaryData.' groups{gg} '.freq=freq;']);
    eval(['summaryData.' groups{gg} '.subjects={popData.subject};']);
    summaryData.freq_labels = freqs;
    summaryData.loc_labels = locs;
end

save(fullfile(savedDataDir, 'population', ['summaryData_EcoG_BandAnalysis2' alignTag poolTag '.mat']), 'summaryData', '-v7.3');
