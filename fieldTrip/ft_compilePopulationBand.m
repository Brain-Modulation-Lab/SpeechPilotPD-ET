% Assemble the population level data for the ET vs PD ECoG analysis

%Note: DBS4053 session 2, no electrode info found.  Need to look into that

%This block is setting the overall parameters of the analysis
setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
%groups = {'ET'};
%ids = {'DBS4*'};
%freq={'broadbandGamma','gamma','hgamma','beta1','beta2','delta','theta','alpha'};
freq={'gamma','hgamma','beta1', 'beta2','delta','theta','alpha'};
%freq={'broadbandGamma'};
%freq={'beta2','delta','theta','alpha'};
subjectLists; %lists of subject IDs
fs = 1000; % data sampling frequency
%subjects = {'DBS4040'};

for gg = 1:length(groups)
    for ff=1:length(freq)
        subjDir = [savedDataDir filesep 'subjects'];
        df = dir([subjDir filesep ids{gg} '_' freq{ff} '*']);
        
        popData = [];
        for ii =1:length(df) % each session file
            load([subjDir filesep df(ii).name]);
            disp(['Loaded ' df(ii).name]);
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
            
            %% Align trials on speech onset for population analysis 
            %center on word onset, -2 to + 2
            trial_starts = num2cell(round(fs*(D.epoch.onset_word - D.epoch.starts)) - 2*fs)';
            trial_ends = num2cell(round(fs*(D.epoch.onset_word - D.epoch.starts)) + 2*fs)';
            trials =  cellfun(@(x,y,z) x(:,y:z),D.signal_z,trial_starts,trial_ends,'UniformOutput',0);
            % redefine baseline
            base_starts = num2cell(round(fs*(D.epoch.stimulus_starts - D.epoch.starts)) - 1 * fs)';
            base_ends = num2cell(round(fs*(D.epoch.stimulus_starts - D.epoch.starts)))';
            base = cellfun(@(x,y,z) x(:,y:z),D.signal_z,base_starts,base_ends,'UniformOutput',0);
            % create a matrix: Time x trial x channela
            basezM = permute(reshape(cell2mat(base), size(base{1},1), size(base{1},2), []), [2 3 1]); 
            trialzM = permute(reshape(cell2mat(trials), size(trials{1},1), size(trials{1},2), []), [2 3 1]); 
            avgZ = squeeze(mean(trialzM, 2)); 
            time = linspace(-2,2,size(trialzM,1));
            zeroi = find(time > 0,1);
            ti = (1:size(basezM,1)) - zeroi + size(basezM,1)/2;
            % Test if each electrode is responsive
            p = NaN*zeros(size(basezM,1), length(usedI));
            h = NaN*zeros(size(basezM,1), length(usedI));
            for jj=1:length(usedI)
                [ep(jj), eh(jj)] = checkElectrodeSignificance(basezM(:,:,jj), trialzM(:,:,jj), zeroi);
                % Get a time-resolved per electrode significance measure
                [p(:,jj), h(:,jj)] = permuteElectrodeSignificance(basezM(:,:,jj), trialzM(:,:,jj), zeroi);
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
            pd.electrodeLoc = elocs;
             
            if (ii==1) popData = pd; else popData(ii) = pd; end   %#ok<SAGROW,SEPEX> Need the if to make this assignment work
        end
        popDir =[savedDataDir filesep 'population' filesep];
        save([popDir 'Pop_ecog_' groups{gg} '_' freq{ff} '.mat'], 'popData', '-v7.3');   
    end
end

