% Time-frequency transormation

%specify machine
DW_machine;
% data sampling frequency and spectral gradient (fq)
fs = 1000;
fq = 2:1:30;

load([dionysis 'Users/dwang/VIM/datafiles/preprocessed_new/v1/' ...
    'DBS4038/ecog/DBS4038_session1_ecog_trials_step3.mat'])

% 1st: remove bad trials
D1 = D;
D1.trial(:,D1.badtrial_final) = [];
D1.time(D1.badtrial_final) = [];
D1.epoch(D1.badtrial_final,:) = [];

% amplitude 
signal = cellfun(@(x) abs(DW_fast_wavtransform(fq, x,fs, 7)),D1.trial(2,:),'UniformOutput',0); % use referenced data


% normalize to baseline
base_starts = num2cell(round((D1.epoch.stimulus_starts - D1.epoch.starts - 1) * fs))';
base_ends = num2cell(round((D1.epoch.stimulus_starts - D1.epoch.starts) * fs))';

bases = cellfun(@(x,y,z) x(y:z,:,:),signal, base_starts, base_ends, 'UniformOutput',0);

bases_mean = cellfun(@(x) mean(x,1),bases,'UniformOutput',0);
bases_std = cellfun(@(x) std(x,0,1),bases,'UniformOutput',0);


signal_norm = cellfun(@(x, y, z) (x - y)./z, signal, bases_mean, bases_std,'UniformOutput',0);

%% ref + word onset centered
%center on word onset, -2 to + 2
roi_starts = num2cell(round(fs*(D1.epoch.onset_word - D1.epoch.starts)) - 2*fs)';
roi_ends = num2cell(round(fs*(D1.epoch.onset_word - D1.epoch.starts)) + 2*fs)';
signal_roi =  cellfun(@(x,y,z) x(y:z,:,:),signal_norm,roi_starts,roi_ends,'UniformOutput',0);
% average sinal_roi across trial
avg_signal_roi = cell2mat(reshape(signal_roi,[1,1,1,size(signal_roi,2)]));
z_oi = mean(avg_signal_roi,4); 

avg_cue = mean(D1.epoch.stimulus_starts - D1.epoch.onset_word);
avg_word_off = mean(D1.epoch.offset_word - D1.epoch.onset_word);

figure; colormap(jet)

t=linspace(-2,2,size(z_oi,1));
imagesc(t, fq, z_oi(:,:,2)');set(gca, 'YDir', 'Normal'); % pick the channel you want

caxis([-2,2]); box on;

hold on; plot([avg_cue,avg_cue],ylim,'k--');
plot([0,0],ylim,'k--'); 
plot([avg_word_off,avg_word_off],ylim,'k--');

xlabel('Time (s)'); % x-axis label
ylabel('Frequency (Hz)'); % y-axis label
colorbar