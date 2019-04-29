% Extract band activity, loop through all of the pre-processed (wide band pass, 60Hz notch, and artifact rejected) data
% for a given subject set, performing narrower band-pass filtering and
% integrating the catagorical electrode localization labels.
setDirectories; %platform specific locations
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
subjectLists; %load lists of subjects
group = 'ET';
subjects = eval([group '_subjects']); %variable contains the proper set
load([codeDir filesep 'Filters' filesep 'bandpassfilters.mat']);
load([codeDir filesep 'Filters' filesep 'highoass_2Hz_fs1200.mat']);
load([codeDir filesep 'Filters' filesep 'BroadbandGammaFilt.mat']);
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};

load([savedDataDir filesep 'population' filesep group '_electrodeInfo.mat']);
electrodeInfo = rmfield(electrodeInfo, 'badch');
electrodeInfo = rmfield(electrodeInfo, 'usedChannels');
eside = {electrodeInfo(:).side};
subj = {electrodeInfo(:).subjectID};

% data sampling frequency
fs = 1000;

for ss=1:length(subjects)
    fdir = [datadir filesep subjects{ss} filesep subjProcessedDir];
    files = dir([fdir filesep subjects{ss} '*_ecog_step5.mat']);
    nsession = length(files);
    for ii = 1:nsession
        load([fdir filesep files(ii).name]);
        % match the electrode file to the data file
        mi = find(strcmp(subjects{ss}, subj) & strncmp(D.side, eside, 1));
        if ~isempty(mi) 
            D.electrodeInfo = electrodeInfo(mi(1)); 
        else
            disp('No matching electrode info for patient found');
        end
        
        for jj = 1:length(freq)
            % 1st: remove bad trials
            D1 = D;
            i_oi = 2; %use Common Average Referenced data
            D1.trial(:,D1.badtrial_final) = [];
            D1.trial = D1.trial(i_oi, :);
            D1.time(D1.badtrial_final) = [];
            D1.epoch(D1.badtrial_final,:) = [];
            
            clearvars signal
            disp(['Filtering at ' freq{jj}]);
            eval(['thesieve=' freq{jj} 'Filt;']);
            signal = cellfun(@(x) abs(hilbert(filtfilt(thesieve,x')))',D1.trial,'UniformOutput',0);
            
            base_starts = num2cell(round(fs*(D1.epoch.stimulus_starts - D1.epoch.starts)) - 1 * fs)';
            base_ends = num2cell(round(fs*(D1.epoch.stimulus_starts - D1.epoch.starts)))';
            base = cellfun(@(x,y,z) x(:,y:z),signal,base_starts,base_ends,'UniformOutput',0);
            baseM = reshape(bm, size(base{1},1), size(base{1},2), []);
            base_mean = cellfun(@(x) mean(x,2), base,'UniformOutput',0);
            
            base_std = cellfun(@(x) std(x,0,2), base,'UniformOutput',0);
            basemean_std = std(squeeze(mean(baseM,3)),0,2); %The STD of the mean across trials for the baseline trace
            
            %signal_norm = cellfun(@(x,y,z) (x-y)./z, signal,base_mean,base_std,'UniformOutput',0);
            signal_z = cellfun(@(x,y) (x-y)./basemean_std, signal,base_mean,'UniformOutput',0);
            
            D1.signal = signal;
            D1.signal_z = signal_z;
            D1.base_mean = base_mean;
            D1.base_std = base_std;
            D1.basemean_std = basemean_std;
            D1.filt = thesieve;
            D1.filtfreq = freq{jj};
            
            %% ref + word onset centered
            %center on word onset, -2 to + 2
            roi_starts = num2cell(round(fs*(D1.epoch.onset_word - D1.epoch.starts)) - 2*fs)';
            roi_ends = num2cell(round(fs*(D1.epoch.onset_word - D1.epoch.starts)) + 2*fs)';
            signal_roi =  cellfun(@(x,y,z) x(:,y:z),signal_z,roi_starts,roi_ends,'UniformOutput',0);
             
            %% Average across all trials
            % average sinal_roi across trial
            avg_signal_roi = cell2mat(signal_roi')';
            
            z_oi = mean(avg_signal_roi, 2);
            
            avg_cue = mean(D1.epoch.stimulus_starts - D1.epoch.onset_word);
            avg_word_off = mean(D1.epoch.offset_word - D1.epoch.onset_word);
            
            % plot
            
            t=linspace(-2,2,size(z_oi,1));
            plot(z_oi)
            
            figure;
            plot(t,z_oi);
            
            hold on; plot([0,0],ylim,'--k');
            hold on; plot([avg_cue,avg_cue],ylim,'--k');
            hold on; plot([avg_word_off,avg_word_off],ylim,'--k');
            
            xlabel('Time (s)'); % x-axis label
            ylabel('High gamma z-score'); % y-axis label
            
            D_back = D;
            D = D1;
            save([savedDataDir filesep 'subjects' filesep subjects{ss} ...
                '_session' num2str(ii) '_ecog_' freq{jj} '.mat'], 'D', '-v7.3');
        end
    end
end