PD_subjectlist = {'DBS2001','DBS2002','DBS2003','DBS2004','DBS2005','DBS2007',...
    'DBS2008','DBS2009','DBS2010','DBS2011','DBS2013','DBS2014','DBS2015',};
 
 ch_session(1,:) = num2cell(extractfield(ch_activity,'Channel'));
 ch_session(2,:) = extractfield(ch_activity,'Session');
 
ch_total = 0; 
for subject_idx = 1:length(PD_subjectlist);
    n_ch = length(DBS2000_elec_idx.elec2mnicort_indx{subject_idx});
    
    for ch_idx = 1:n_ch;
        ch_total = ch_total +1;
    
        loc_activity_pair(ch_total).patient = PD_subjectlist{subject_idx};
        
        loc_activity_pair(ch_total).channel = ch_idx;
        
        loc_activity_pair(ch_total).vertex_idx = DBS2000_elec_idx.elec2mnicort_indx{subject_idx}(ch_idx,1);
        
        matched_ch_session = [];
        for i = 1:length(ch_activity);
            
            if ch_session{1,i} == ch_idx & strcmp(ch_session{2,i}(1:7),PD_subjectlist{subject_idx});
                matched_ch_session = [matched_ch_session,i];
            end
        end
            sessions_for_one_ch = ch_activity(matched_ch_session);
            
            if length(sessions_for_one_ch) >0;
            
                alpha_activity = extractfield(sessions_for_one_ch,'alpha');

                loc_activity_pair(ch_total).alpha = [mean(alpha_activity(1:2:end)),mean(alpha_activity(2:2:end))];
                
                beta2_activity = extractfield(sessions_for_one_ch,'beta2');
                
                loc_activity_pair(ch_total).beta2 = [mean(beta2_activity(1:2:end)),mean(beta2_activity(2:2:end))];
                
                beta1_activity = extractfield(sessions_for_one_ch,'beta1');
                
                loc_activity_pair(ch_total).beta1 = [mean(beta1_activity(1:2:end)),mean(beta1_activity(2:2:end))];
                
                Hgamma_activity = extractfield(sessions_for_one_ch,'Hgamma');
                
                loc_activity_pair(ch_total).Hgamma = [mean(Hgamma_activity(1:2:end)),mean(Hgamma_activity(2:2:end))];
                
                
                Gamma_activity = extractfield(sessions_for_one_ch,'Gamma');
                
                loc_activity_pair(ch_total).Gamma = [mean(Gamma_activity(1:2:end)),mean(Gamma_activity(2:2:end))];
                
                
                BroadbandGamma_activity = extractfield(sessions_for_one_ch,'BroadbandGamma');
                
                loc_activity_pair(ch_total).BroadbandGamma = [mean(BroadbandGamma_activity(1:2:end)),mean(BroadbandGamma_activity(2:2:end))];
            else
                loc_activity_pair(ch_total).alpha = NaN;
                loc_activity_pair(ch_total).beta2 = NaN;
                loc_activity_pair(ch_total).beta1 = NaN;
                loc_activity_pair(ch_total).Hgamma = NaN;
                loc_activity_pair(ch_total).Gamma = NaN;
                loc_activity_pair(ch_total).BroadbandGamma = NaN;
            end
    end
end

save('loc_activity_pair_z','loc_activity_pair')
                
                
                
                


        
        
        
        
    

