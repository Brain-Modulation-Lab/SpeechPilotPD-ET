PD_subjectlist = {'DBS2001','DBS2002','DBS2003','DBS2004','DBS2006','DBS2007',...
    'DBS2008','DBS2009','DBS2010','DBS2011','DBS2013','DBS2014','DBS2015',};

load('/Volumes/Nexus/Users/dwang/ET-PD/datafiles/ch_activity_t_PD.mat');
load('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/DBS2000_elec_idx.mat');
match_tb = readtable('/Volumes/Nexus/Users/dwang/ET-PD/datafiles/ch-contact-match.xlsx');
 addpath('/Applications/MATLAB_R2017b.app/toolbox/map/map') % Add extractfield function to path
 ch_session(1,:) = num2cell(extractfield(ch_activity,'Channel'));
 ch_session(2,:) = extractfield(ch_activity,'Session'); % channel-session correspondence
 
 contact_total = 0; 
 
 
for subject_idx = 1:length(PD_subjectlist);
    n_contact = length(DBS2000_elec_idx.elec2mnicort_indx{subject_idx}); % number of contact for this patient
    
    for contact_idx = 1:n_contact;
        contact_total = contact_total +1;
        ch_idx = [];
        % find the corresponding channel index
        for ii = 1:height(match_tb);
            if isequal(match_tb.Patient(ii),PD_subjectlist(subject_idx)) & ...
                    match_tb.Contact(ii) == contact_idx;
                ch_idx = match_tb.Channel(ii);
            end
        end
        
    
        loc_activity_pair(contact_total).patient = PD_subjectlist{subject_idx};
        
        loc_activity_pair(contact_total).contact = contact_idx;
        
        loc_activity_pair(contact_total).channel = ch_idx;
        
        loc_activity_pair(contact_total).vertex_idx = DBS2000_elec_idx.elec2mnicort_indx{subject_idx}(contact_idx,1);
        
        matched_ch_session = [];
        for i = 1:length(ch_activity);
            
            if ch_session{1,i} == ch_idx & strcmp(ch_session{2,i}(1:7),PD_subjectlist{subject_idx});
                matched_ch_session = [matched_ch_session,i];
            end
        end
            sessions_for_one_ch = ch_activity(matched_ch_session);
            % find the sessions one channel has and then combine sessions
            
            if length(sessions_for_one_ch) >0;
                alpha_activity = [];
                beta2_activity = [];
                beta1_activity = [];
                Hgamma_activity = [];
                Gamma_activity = [];
                BroadbandGamma_activity = [];
                for ii = 1:length(sessions_for_one_ch);
                   alpha_activity = [alpha_activity;sessions_for_one_ch(ii).alpha];
                end

                [~,~,~,cue_stat] = ttest2(alpha_activity(:,2),alpha_activity(:,1),'Vartype','unequal','Tail','left');
                [~,~,~,onset_stat] = ttest2(alpha_activity(:,3),alpha_activity(:,1),'Vartype','unequal','Tail','left');

                alpha_t = [cue_stat.tstat,onset_stat.tstat];
            
                

                loc_activity_pair(contact_total).alpha = alpha_t;
                
                for ii = 1:length(sessions_for_one_ch);
                   beta2_activity = [beta2_activity;sessions_for_one_ch(ii).beta2];
                end

                [~,~,~,cue_stat] = ttest2(beta2_activity(:,2),beta2_activity(:,1),'Vartype','unequal','Tail','left');
                [~,~,~,onset_stat] = ttest2(beta2_activity(:,3),beta2_activity(:,1),'Vartype','unequal','Tail','left');

                beta2_t = [cue_stat.tstat,onset_stat.tstat];
            
                

                loc_activity_pair(contact_total).beta2 = beta2_t;
                
                for ii = 1:length(sessions_for_one_ch);
                   beta1_activity = [beta1_activity;sessions_for_one_ch(ii).beta1];
                end

                [~,~,~,cue_stat] = ttest2(beta1_activity(:,2),beta1_activity(:,1),'Vartype','unequal','Tail','left');
                [~,~,~,onset_stat] = ttest2(beta1_activity(:,3),beta1_activity(:,1),'Vartype','unequal','Tail','left');

                beta1_t = [cue_stat.tstat,onset_stat.tstat];
            
                

                loc_activity_pair(contact_total).beta1 = beta1_t;
                
                for ii = 1:length(sessions_for_one_ch);
                   Hgamma_activity = [Hgamma_activity;sessions_for_one_ch(ii).Hgamma];
                end

                [~,~,~,cue_stat] = ttest2(Hgamma_activity(:,2),Hgamma_activity(:,1),'Vartype','unequal','Tail','left');
                [~,~,~,onset_stat] = ttest2(Hgamma_activity(:,3),Hgamma_activity(:,1),'Vartype','unequal','Tail','left');

                Hgamma_t = [cue_stat.tstat,onset_stat.tstat];
            
                

                loc_activity_pair(contact_total).Hgamma = Hgamma_t;
                
                
                for ii = 1:length(sessions_for_one_ch);
                   Gamma_activity = [Gamma_activity;sessions_for_one_ch(ii).Gamma];
                end

                [~,~,~,cue_stat] = ttest2(Gamma_activity(:,2),Gamma_activity(:,1),'Vartype','unequal','Tail','left');
                [~,~,~,onset_stat] = ttest2(Gamma_activity(:,3),Gamma_activity(:,1),'Vartype','unequal','Tail','left');

                Gamma_t = [cue_stat.tstat,onset_stat.tstat];
            
                

                loc_activity_pair(contact_total).Gamma = Gamma_t;
                
                for ii = 1:length(sessions_for_one_ch);
                   BroadbandGamma_activity = [BroadbandGamma_activity;sessions_for_one_ch(ii).BroadbandGamma];
                end

                [~,~,~,cue_stat] = ttest2(BroadbandGamma_activity(:,2),BroadbandGamma_activity(:,1),'Vartype','unequal','Tail','left');
                [~,~,~,onset_stat] = ttest2(BroadbandGamma_activity(:,3),BroadbandGamma_activity(:,1),'Vartype','unequal','Tail','left');

                BroadbandGamma_t = [cue_stat.tstat,onset_stat.tstat];
            
                

                loc_activity_pair(contact_total).BroadbandGamma = BroadbandGamma_t;
            else
                loc_activity_pair(contact_total).alpha = NaN;
                loc_activity_pair(contact_total).beta2 = NaN;
                loc_activity_pair(contact_total).beta1 = NaN;
                loc_activity_pair(contact_total).Hgamma = NaN;
                loc_activity_pair(contact_total).Gamma = NaN;
                loc_activity_pair(contact_total).BroadbandGamma = NaN;
            end
    end
end

save('loc_activity_pair_t_PD','loc_activity_pair')