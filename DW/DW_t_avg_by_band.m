fs = 1200;
ch_total = 0;
for session_idx = 1:length(Results);
    chUsed = Results(session_idx).Cue.parameters{16};
    trUsed = Results(session_idx).Cue.parameters{10};
    cue_index = Results(session_idx).Cue.parameters{2}*fs; % index of cue onset for this session
    onset_index = Results(session_idx).Onset.parameters{2}*fs; % index of speech onset for this session
    cue_trial_length = length(Results(session_idx).Cue.meanPSD); % length of cue Pete use
    onset_trial_length = length(Results(session_idx).Onset.meanPSD); % length of speech pete use
    
    
    cue_post_length = (Results(session_idx).trials.SpOnset - Results(session_idx).trials.BaseBack); % real length of post-cue period
    onset_post_length = (Results(session_idx).trials.SpOffset - Results(session_idx).trials.SpOnset); % real length of post-speech period
    
    
    cue_period = [repmat(round(cue_index),1,length(trUsed));...
        (round(cue_post_length((trUsed))*fs + cue_index))']; % real cue-period
    cue_period(find(cue_period>cue_trial_length)) = cue_trial_length; % if real cue-period exceeds the length, then use the period pete chooses
    
    onset_period = [repmat(round(onset_index),1,length(trUsed));...
        (round(onset_post_length((trUsed))*fs+onset_index))']; % real onset-period
    
    onset_period(find(onset_period>onset_trial_length)) = onset_trial_length;% if real sp-period exceeds the length, then use the period pete chooses
    
    
    
    for ch_idx = 1:length(chUsed);
        ch_total = ch_total + 1;
        ch_activity(ch_total).Channel = chUsed(ch_idx);
        ch_activity(ch_total).Session = Results(session_idx).Session;
        
        %alpha
        trialbych_alpha_cue = Results(session_idx).Cue.alpha.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_alpha_onset = Results(session_idx).Onset.alpha.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_alpha_base = Results(session_idx).Cue.alpha.z_Amp(1:500,ch_idx:length(chUsed):end);
        
        

        alpha_activity_cue = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_alpha_cue,[1,length(trUsed)]),...
            num2cell(cue_period,[1,length(trUsed)]),...
            'Uni',0))';
        alpha_activity_onset = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_alpha_onset,[1,length(trUsed)]),...
            num2cell(onset_period,[1,length(trUsed)]),...
            'Uni',0))';
        alpha_base = mean(trialbych_alpha_base,1)';
        alpha_all = [alpha_base,alpha_activity_cue,alpha_activity_onset]; % for each channel and each trial, we get average base, cue and speech data
        


        
        
        
        ch_activity(ch_total).alpha = alpha_all;
        
%         %theta
%         
%         trialbych_theta_cue = Results(session_idx).Cue.theta.z_Amp(:,ch_idx:length(chUsed):end);
%         trialbych_theta_onset = Results(session_idx).Onset.theta.z_Amp(:,ch_idx:length(chUsed):end);
%         
%         theta_activity_cue = mean(cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
%             num2cell(trialbych_theta_cue,[1,length(trUsed)]),...
%             num2cell(cue_period,[1,length(trUsed)]),...
%             'Uni',0)));
%         theta_activity_onset = mean(cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
%             num2cell(trialbych_theta_onset,[1,length(trUsed)]),...
%             num2cell(onset_period,[1,length(trUsed)]),...
%             'Uni',0)));
%         
%         
%         
%         ch_activity(ch_total).theta = [theta_activity_cue,theta_activity_onset];
%         
%         %delta
%         
%         
%         trialbych_delta_cue = Results(session_idx).Cue.delta.z_Amp(:,ch_idx:length(chUsed):end);
%         trialbych_delta_onset = Results(session_idx).Onset.delta.z_Amp(:,ch_idx:length(chUsed):end);
%         
%         delta_activity_cue = mean(cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
%             num2cell(trialbych_delta_cue,[1,length(trUsed)]),...
%             num2cell(cue_period,[1,length(trUsed)]),...
%             'Uni',0)));
%         delta_activity_onset = mean(cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
%             num2cell(trialbych_delta_onset,[1,length(trUsed)]),...
%             num2cell(onset_period,[1,length(trUsed)]),...
%             'Uni',0)));
%         
%         
%         ch_activity(ch_total).delta = [delta_activity_cue,delta_activity_onset];
%         
        %beta2
        
        trialbych_beta2_cue = Results(session_idx).Cue.beta2.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_beta2_onset = Results(session_idx).Onset.beta2.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_beta2_base = Results(session_idx).Cue.beta2.z_Amp(1:500,ch_idx:length(chUsed):end);
        
        beta2_activity_cue = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_beta2_cue,[1,length(trUsed)]),...
            num2cell(cue_period,[1,length(trUsed)]),...
            'Uni',0))';
        beta2_activity_onset = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_beta2_onset,[1,length(trUsed)]),...
            num2cell(onset_period,[1,length(trUsed)]),...
            'Uni',0))';
        
        beta2_base = mean(trialbych_beta2_base,1)';
        beta2_all = [beta2_base,beta2_activity_cue,beta2_activity_onset];        

       
        ch_activity(ch_total).beta2 = beta2_all;
        
        %beta1
        
        trialbych_beta1_cue = Results(session_idx).Cue.beta1.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_beta1_onset = Results(session_idx).Onset.beta1.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_beta1_base = Results(session_idx).Cue.beta1.z_Amp(1:500,ch_idx:length(chUsed):end);
        
        beta1_activity_cue = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_beta1_cue,[1,length(trUsed)]),...
            num2cell(cue_period,[1,length(trUsed)]),...
            'Uni',0))';
        beta1_activity_onset = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_beta1_onset,[1,length(trUsed)]),...
            num2cell(onset_period,[1,length(trUsed)]),...
            'Uni',0))';
        
        beta1_base = mean(trialbych_beta1_base,1)';
        beta1_all = [beta1_base,beta1_activity_cue,beta1_activity_onset];        

       
        ch_activity(ch_total).beta1 = beta1_all;
        
%Hgamma
        
        trialbych_Hgamma_cue = Results(session_idx).Cue.Hgamma.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_Hgamma_onset = Results(session_idx).Onset.Hgamma.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_Hgamma_base = Results(session_idx).Cue.Hgamma.z_Amp(1:500,ch_idx:length(chUsed):end);        
        
        Hgamma_activity_cue = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_Hgamma_cue,[1,length(trUsed)]),...
            num2cell(cue_period,[1,length(trUsed)]),...
            'Uni',0))';
        Hgamma_activity_onset = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_Hgamma_onset,[1,length(trUsed)]),...
            num2cell(onset_period,[1,length(trUsed)]),...
            'Uni',0))';
        
        Hgamma_base = mean(trialbych_Hgamma_base,1)';
        Hgamma_all = [Hgamma_base,Hgamma_activity_cue,Hgamma_activity_onset];          

       
        ch_activity(ch_total).Hgamma = Hgamma_all;
        
        
        %Gamma
        trialbych_Gamma_cue = Results(session_idx).Cue.Gamma.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_Gamma_onset = Results(session_idx).Onset.Gamma.z_Amp(:,ch_idx:length(chUsed):end);
         trialbych_Gamma_base = Results(session_idx).Cue.Gamma.z_Amp(1:500,ch_idx:length(chUsed):end);
         
         
        Gamma_activity_cue = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_Gamma_cue,[1,length(trUsed)]),...
            num2cell(cue_period,[1,length(trUsed)]),...
            'Uni',0))';
        Gamma_activity_onset = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_Gamma_onset,[1,length(trUsed)]),...
            num2cell(onset_period,[1,length(trUsed)]),...
            'Uni',0))';
        Gamma_base = mean(trialbych_Gamma_base,1)';
        Gamma_all = [Gamma_base,Gamma_activity_cue,Gamma_activity_onset];

       
        ch_activity(ch_total).Gamma = Gamma_all;
        
        
        %BroadbandGamma
        trialbych_BroadbandGamma_cue = Results(session_idx).Cue.BroadbandGamma.z_Amp(:,ch_idx:length(chUsed):end);
        trialbych_BroadbandGamma_onset = Results(session_idx).Onset.BroadbandGamma.z_Amp(:,ch_idx:length(chUsed):end);
          trialbych_BroadbandGamma_base = Results(session_idx).Cue.BroadbandGamma.z_Amp(1:500,ch_idx:length(chUsed):end); 
          
        BroadbandGamma_activity_cue = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_BroadbandGamma_cue,[1,length(trUsed)]),...
            num2cell(cue_period,[1,length(trUsed)]),...
            'Uni',0))';
        BroadbandGamma_activity_onset = cell2mat(cellfun(@(x,y) mean(x(y(1):y(2))),...
            num2cell(trialbych_BroadbandGamma_onset,[1,length(trUsed)]),...
            num2cell(onset_period,[1,length(trUsed)]),...
            'Uni',0))';
        
        BroadbandGamma_base = mean(trialbych_BroadbandGamma_base,1)';
        BroadbandGamma_all = [BroadbandGamma_base,BroadbandGamma_activity_cue,BroadbandGamma_activity_onset];

       
        ch_activity(ch_total).BroadbandGamma = BroadbandGamma_all;
    end
end

save('ch_activity_t_PD.mat','ch_activity');