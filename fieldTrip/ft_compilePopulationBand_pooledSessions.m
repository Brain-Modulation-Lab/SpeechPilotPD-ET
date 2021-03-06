% compilePopulationBand_pooledSessions.m
% Assemble the population level data for the ET vs PD ECoG analysis

%This block is setting the overall parameters of the analysis
setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
%groups = {'ET'};
%ids = {'DBS4*'};
freq={'hgamma','beta1', 'beta2','gamma','delta','theta','alpha'}; %current full set ('broadbandGamma' no longer doing)
%freq={'delta','theta','alpha'};
subjectLists; %lists of subject IDs
fs = 1000; % data sampling frequency
base_dur = 1; %baseline duration in sec
alignOnset = 1; %Flag for time alignment on 0= Cue to speak, 1=Speech onset
poolSessions = 1;
alignCue = 0;

if poolSessions
    poolTag = '_pooledSessions';
else
    poolTag = '';
end
if alignCue
    alignTag = '_alignCue';
else
    alignTag = '_alignOnset';
end

for gg = 1:length(groups)
    %sg provides groupings of sessions with identical electrode positions, used to pool sessions
    %popData is actually generated by the non-pooled session version of this script, solely because it's
    % easier to work with the already processed data strucure. NOT IDEAL IF UNDERLYING DATA WERE TO CHANGE
    load([savedDataDir filesep 'population' filesep 'Pop_ecog_' groups{gg} '_hgamma' alignTag '.mat']);
    [electID, sg] = uniqueElectrodes(popData);
    
    for ff=1:length(freq)
        subjDir = [savedDataDir filesep 'subjects'];
        df = dir([subjDir filesep ids{gg} '_' freq{ff} '*']);
        
        popData = [];
        for ss = 1:length(sg)
            sessList = sg{ss};
            ns = length(sg{ss});
            for ii =1:ns % each session file
                sessNum = sessList(ii);
                load([subjDir filesep df(sessNum).name]);
                disp(['Loaded ' df(sessNum).name]);
                clear pd ep eh;
                
                %set up the population data structures
                nchan = length(D.electrodeInfo.location);
                if ~isempty(D.badch) %need to get indices of bad channels rather than strings
                    [used_label, usedI] = setdiff(D.label_br, D.badch);
                    missing = setdiff(1:nchan, usedI);
                    elocs = D.electrodeInfo.location(usedI);
                else
                    usedI = 1:nchan;
                    elocs = D.electrodeInfo.location(usedI);
                end
                
                if alignOnset
                    %% Align trials on speech onset for population analysis
                    %center on word onset, -2 to + 2sec
                    t_range = [-2 2];
                    trial_starts = num2cell(round(fs*(D.epoch.onset_word - D.epoch.starts)) - 2*fs)';
                    trial_ends = num2cell(round(fs*(D.epoch.onset_word - D.epoch.starts)) + 2*fs)';
                    trials =  cellfun(@(x,y,z) x(:,y:z),D.signal_z,trial_starts,trial_ends,'UniformOutput',0);
                    filetag='alignOnset';
                    permute_range = [-1 2]; %time range broken up by 1 sec segments (baseline 1 sec)
                else
                    %Aligns on the Cue to speak: -1sec to 3 sec
                    t_range = [-1 2.5];
                    trial_starts = num2cell(round(fs*(D.epoch.stimulus_starts - D.epoch.starts)) + t_range(1)*fs)';
                    trial_ends = num2cell(round(fs*(D.epoch.stimulus_starts - D.epoch.starts)) + t_range(2)*fs)';
                    trials =  cellfun(@(x,y,z) x(:,y:z),D.signal_z,trial_starts,trial_ends,'UniformOutput',0);
                    filetag = 'alignCue';
                    permute_range = [0 2]; 
                end
                % redefine baseline
                base_starts = num2cell(round(fs*(D.epoch.stimulus_starts - D.epoch.starts)) - 1 * fs)';
                base_ends = num2cell(round(fs*(D.epoch.stimulus_starts - D.epoch.starts)))';
                base = cellfun(@(x,y,z) x(:,y:z),D.signal_z,base_starts,base_ends,'UniformOutput',0);
                % create a matrix: Time x trial x channels
                bM = permute(reshape(cell2mat(base), size(base{1},1), size(base{1},2), []), [2 3 1]);
                tM = permute(reshape(cell2mat(trials), size(trials{1},1), size(trials{1},2), []), [2 3 1]);
                if ii==1
                    basezM = bM;
                    trialzM = tM;
                    % do some collation 
                    badtrial = {D.badtrial_final}; 
                    epoch = {D.epoch};
                    badch = {D.badch};
                else
                    basezM = cat(2, basezM, bM);
                    trialzM = cat(2, trialzM, tM);
                    badtrial{ii} = D.badtrial_final;
                    epoch{ii} = D.epoch;
                    badch{ii} = D.badch;
                end
                if ii == ns
                    avgZ = squeeze(mean(trialzM, 2));
                    
                    time = linspace(t_range(1),t_range(2),size(trialzM,1));
                    zeroi = find(time > 0,1);
                    ti = (1:size(basezM,1)) - zeroi + size(basezM,1)/2;
                    % Test if each electrode is responsive
                    % Test if each electrode is responsive
                    p = NaN*zeros(fs * diff(permute_range)+1, length(usedI));
                    h = NaN*zeros(fs * diff(permute_range)+1, length(usedI));
                    for jj=1:length(usedI)
                        [ep(jj), eh(jj)] = checkElectrodeSignificance(basezM(:,:,jj), trialzM(:,:,jj), zeroi);
                        % Get a time-resolved per electrode significance measure
                        nseg = diff(permute_range) / base_dur;
                        %inds = permute_range*fs + zeroi;
                        lasti = permute_range(1)*fs - 2 + zeroi;
                        bn = (base_dur*fs);
                        for kk=1:nseg
                            inds = lasti + (1:(base_dur*fs));
                            pind = (kk-1)*bn + (1:(base_dur*fs));
                            [p(pind,jj), h(pind,jj)] = permuteElectrodeSignificance(basezM(1:end-1,:,jj), trialzM(:,:,jj), inds(1));
                            lasti = inds(end);
                        end
                    end
                end
            end
            
            pd = D;
            pd = rmfield(pd, {'trial', 'time', 'filt', 'signal_z', 'signal'});
            pd.basezM = basezM;
            pd.trialzM = trialzM;
            pd.meanz = avgZ;
            pd.time = time;
            pd.sig_p = ep;
            pd.sig_h = eh;
            pd.clusterT_p = p;
            pd.clusterT_h = h;
            pd.clusterT_t = permute_range;
            pd.electrodeLoc = elocs;
            pd.alignment = filetag;
            pd.badch = badch;
            pd.epoch = epoch;
            pd.badtrial_final = badtrial;
            
            if (ss==1) popData = pd; else popData(ss) = pd; end   %#ok<SAGROW,SEPEX> Need the if to make this assignment work
            
        end
        popDir =[savedDataDir filesep 'population' filesep];
        save([popDir 'Pop_ecog_' groups{gg} '_' freq{ff} '_' filetag '_pooledSessions.mat'], 'popData', '-v7.3');
    end
end

