% extract band activity

%specify machine
DW_machine;
% data sampling frequency
fs = 1000;

load([dionysis 'Users/dwang/VIM/datafiles/preprocessed_new/v1/' ...
    'DBS4038/ecog/DBS4038_session1_ecog_trials_step3.mat'])

% 1st: remove bad trials
D1 = D;
D1.trial(:,D1.badtrial_final) = [];
D1.time(D1.badtrial_final) = [];
D1.epoch(D1.badtrial_final,:) = [];

%filter load
load([dropbox,'Filter/bpFilt.mat']);

        
i_oi = 2;
        
D_used = [];

D_used.trial = cellfun(@(x) x(i_oi,:),D1.trial,'UniformOutput',0);

D_used.epoch = D1.epoch;

D_used.time = D1.time;
        
clearvars signal
        
signal = cellfun(@(x) abs(hilbert(filtfilt(hgammaFilt,x')))',D_used.trial(2,:),'UniformOutput',0);

base_starts = num2cell(round(fs*(D_used.epoch.stimulus_starts - D_used.epoch.starts)) - 1 * fs)';
base_ends = num2cell(round(fs*(D_used.epoch.stimulus_starts - D_used.epoch.starts)))';

bases = cellfun(@(x,y,z) x(:,y:z),signal,base_starts,base_ends,'UniformOutput',0);

bases_mean = cellfun(@(x) mean(x), bases,'UniformOutput',0);
bases_std = cellfun(@(x) std(x,0), bases,'UniformOutput',0);

signal_norm = cellfun(@(x,y,z) (x-y)./z, signal,bases_mean,bases_std,'UniformOutput',0);

%% ref + word onset centered
%center on word onset, -2 to + 2
roi_starts = num2cell(round(fs*(D1.epoch.onset_word - D1.epoch.starts)) - 2*fs)';
roi_ends = num2cell(round(fs*(D1.epoch.onset_word - D1.epoch.starts)) + 2*fs)';
signal_roi =  cellfun(@(x,y,z) x(:,y:z),signal_norm,roi_starts,roi_ends,'UniformOutput',0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%% if only average across word trials, run this chunk
word_idx = find(D_used.epoch.trial_id <=60 & mod(D_used.epoch.trial_id,2)==0);
nonword_idx = find(D_used.epoch.trial_id <=60 & mod(D_used.epoch.trial_id,2)==1);

word_trials = signal_roi(word_idx);
nonword_trials = signal_roi(nonword_idx);

z_word = mean(cell2mat(word_trials')',2); 
z_nonword = mean(cell2mat(nonword_trials')',2);

figure; hold on;
t=linspace(-2,2,size(z_oi,1));
plot(t, z_word)
plot(t, z_nonword)
%%%%%%%%%%%%%%%%%%%%%

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