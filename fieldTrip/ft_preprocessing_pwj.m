%% Preprocessing of the dataset from the fieldTrip imported data files

setDirectories; %platform specific locations 
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
subjectLists; %load lists of subjects
group = 'ET';
subjects = eval([group '_subjects']); %variable contains the proper set
load([savedDataDir filesep 'population' filesep group '_electrodeInfo.mat']);

%% Step 1: tear apart subcortical and cortical channels, create a file that
% includes only audio and ecog channels, for each session. Also, register
% the bad channels as previously detected and the electrode localizations
% based on individual reconstructions
%for ii=1:2
for ii=8:length(subjects)
    fn = [datadir filesep subjects{ii} filesep 'Preprocessed Data' filesep 'FieldTrip' filesep subjects{ii} '_ft_raw_session.mat'];
    disp(['loading ' fn]);
    load(fn);
    
    subSel = strcmp({electrodeInfo.subjectID}, subjects{ii});
    sessionNums = [electrodeInfo(subSel).session];
    electrodeInds = find(subSel);
    si = 1;
    if strcmp(subjects{ii}, 'DBS2009') sessionNums = [1,2]; end %doesn't work for DBS2009
    for which_session = sessionNums % deal with one session at a time
        clearvars ecog_ch_idx audio_ch_idx select_ch_idx D_select D_backup
        ecog_ch_idx = find(strcmp('ecog',cellfun(@(x) x(1:4),D.label,'UniformOutput',0))); % ecog channels
        audio_ch_idx(1,:) = find(strcmp('audio_p',D.label)); audio_ch_idx(2,:) = find(strcmp('envaudio_p',D.label)); % audio channels
        select_ch_idx = [ecog_ch_idx;audio_ch_idx];
        
        D_select.label = D.label(select_ch_idx);% extract ecog and audio
        D_select.time(1) = D.time(which_session);
        D_select.trial{1} = D.trial{which_session}(select_ch_idx,:);
        D_select.cfg = D.cfg; % just copy
       
        %make hdr for D_select
        hdr = [];
        hdr.Fs=1000;
        hdr.nChans=length(D_select.label);
        hdr.nSamples=sum(cellfun(@(x)size(x,2),D_select.trial));
        hdr.nSamplesPre=0;
        hdr.nTrials=length(D_select.trial);
        hdr.label=D_select.label;
        hdr.chantype=split(D_select.label,'_');
        hdr.chantype=hdr.chantype(:,1);
        hdr.chanunit=[repmat({'uV'},size(D_select.trial{1},1)-2,1);{'au';'au'}];
        hdr.subj = subjects{ii};
        hdr.session = which_session;
        if strcmp(subjects{ii}, 'DBS2009') hdr.session = which_session+2; end %doesn't work for DBS2009
        hdr.electrodeInfo = electrodeInfo(electrodeInds(si));
        
        D_select.hdr = hdr;        
        % save
        D_backup = D; %switch out the full 
        D =D_select; %single session D
        session_epoch = loaded_epoch(which_session,:);
        
        save_fn = [savedDataDir filesep 'subjects' filesep subjects{ii} '_session' num2str(which_session) '_ecog.mat'];
        save(save_fn,'D','session_epoch','-v7.3');
        D = D_backup;
        si = si+1;
    end
end

%% Stage 2 -  loop through adding D.badch field for each file, incorporating the 
% individual electrode locations (experimentor determined from individual
% reconstructions) into the structure too.
ft_defaults;
bml_defaults;
dd = dir([savedDataDir filesep 'subjects' filesep '*_ecog.mat']);

for session_idx = 3:length(dd)
    load([dd(session_idx).folder filesep dd(session_idx).name]);
    
    cfg=[];
    cfg.viewmode = 'vertical';
    cfg.continuous = 'yes';
    cfg.blocksize = 30;
    ft_databrowser(cfg,D);
    
    %get the bad channels from the previous annotation
    badch_prev = D.hdr.electrodeInfo.badch;
    
    disp(dd(session_idx).name); 
    disp(['Previously marked bad channels: ' num2str(badch_prev)]);
    badch = input('Indicate bad channel indexes:');

    close all
    D.badch = badch
    D.state = 'downsampled to 1khz, badch detected';

    save([savedDataDir filesep 'subjects' filesep ...
    dd(session_idx).name(1:end-4) '_step1.mat'],'D','session_epoch','-v7.3');
end

