% Assemble the population level data for the ET vs PD ECoG analysis

%Note: DBS4053 session 2, no electrode info found.  Need to look into that

%This block is setting the overall parameters of the analysis
setDirectories; %platform specific locations
groups = {'PD', 'ET'};
ids = {'DBS2*', 'DBS4*'};
freq={'broadbandGamma','gamma','hgamma','beta1','beta2','delta','theta','alpha'};
subjectLists; %lists of subject IDs
fs = 1000; % data sampling frequency


for gg = 1:length(groups)
    for ff=1:length(freq)
        subjDir = [savedDataDir filesep 'subjects'];
        df = dir([subjDir filesep ids{gg} freq{ff} '*']);
        
        popData = [];
        for ii =1:length(df) % each session file
            load([subjDir filesep df(ii).name]);
            clear pd;
            
            %set up the population data structures
            nchan = length(D.electrodeInfo.electrodeLoc);
            if ~isempty(D.badch) %need to get indices of bad channels rather than strings
                [used_label, usedI] = setdiff(D.label_br, D.badch);
                missing = setdiff(1:nchan, usedI);
                elocs = D.electrodeInfo.electrodeLoc(usedI);
            else
                usedI = 1:nchan;
                elocs = D.electrodeInfo.electrodeLoc(usedI);
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
            % create a matrix: Time x trial x channel
            baseM = permute(reshape(cell2mat(base), size(base{1},1), size(base{1},2), []), [2 3 1]); 
            trialM = permute(reshape(cell2mat(trials), size(trials{1},1), size(trials{1},2), []), [2 3 1]); 
            avgZ = squeeze(mean(trialM, 2));
            
            % Test if each electrode is responsive
            
            
            pd.basezM = basezM;
            pd.trialzM = trialzM;
            pd.meanz = squeeze(mean(trialM, 2));
            pd.time = linspace(-2,2,size(trialM,1));
        end
   
    
    
    
    end
end

