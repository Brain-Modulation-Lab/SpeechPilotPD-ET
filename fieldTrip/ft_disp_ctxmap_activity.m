% Plotting the electrode locations and eventually a mapping of activity
% This will plot activity for each electrode location

setDirectories; %platform specific locations
%can load one of the subject group data files for all sessions
% load('Pop_ecog_ET_hgamma.mat');
% pd = popData;
% load('Pop_ecog_PD_hgamma.mat');
% pd = popData;

%These are for the MNI brain, not necessary now
%BS1 structure
%load([savedDataDir filesep 'population' filesep 'cortex_MNI.mat']);
%DispCamPos1 structure
%load([savedDataDir filesep 'population' filesep 'DispCamPos1.mat']);

%Want to display all of the individual response maps on the subject's anatomy
for ii=1:length(pd) 
    %Individual anatomy
    suffix = ['Anatomy' filesep 'FreeSurfer' filesep 'postop'];
    load([datadir filesep pd(ii).subject filesep suffix filesep 'cortex_indiv.mat']);
    hull = load([datadir filesep pd(ii).subject filesep suffix filesep 'hull.mat']);
    
    %% Plot the cortical surface
    fh = figure; hold on;
    Hp = patch('vertices',cortex.vert,'faces',cortex.tri,...
        'facecolor',[.85 .50 .50],'edgecolor','none',...
        'facelighting', 'gouraud', 'specularstrength', .50);
    camlight('headlight','infinite');
    axis off; axis equal
    set(gca,'CameraPosition',DispCamPos1.cp,'CameraTarget',DispCamPos1.ct,...
        'CameraViewAngle',DispCamPos1.cva, 'CameraUpVector',DispCamPos1.uv);
    alpha 1
    hold on;
    
    %%

    ecoord = pd(ii).electrodeInfo.native_coord;
    activity = max(pd(ii).meanz);
    for jj=1:length(pd(ii).electrodeLoc)
        
        %first pass - just plot the points in a colorscale
        % determine color range
        %all_val = colored_V_allband(:);
        c_range = [-2,15];
        clmp = jet;
        color_pctile = min((activity(jj) - c_range(1))/(c_range(2)-c_range(1)),1) ;
        V_color(jj) = floor(color_pctile * 64);
        plot3(ecoord(jj,1), ecoord(jj,2), ecoord(jj,3), 'Marker', '.', 'Color', clmp(V_color(jj),:), 'MarkerSize', 15);
        
       
        %vertidx_t_pair_ynan = vertidx_t_pair;
        %vertidx_t_pair(find(isnan(vertidx_t_pair(:,13))),:) = []; %get vertex index-activity paired, remove nan
        %order:cue, onset; alpha,beta2,beta1,Hgamma,Gamma,BroadbandGamma
        ra = 3; % radius of full activity, subject to change
        ddecay = 13; % decay distance, subject to change

        V = [];
        for all_vert_idx = 1:length(cortex.vert)
            
            % for each vertex, find if it's within radius of any contact
            %within_ra = find(pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(:,1),:))<=ra);
            within_ra = find(pdist2(cortex.vert(all_vert_idx,:),ecoord)<=ra);
            %for each vertex, find if it's within decay of any contact
            %within_decay = find(pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(:,1),:))>ra & ...
            %    pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(:,1),:)) <= ddecay);
            within_decay = find(pdist2(cortex.vert(all_vert_idx,:),ecoord)>ra & ...
                pdist2(cortex.vert(all_vert_idx,:),ecoord) <= ddecay);
            dist = pdist2(cortex.vert(all_vert_idx,:),cortex.vert(within_decay,:));
            % get the distance between current vertex and within-decay contacts
            
            %           if isempty(max([vertidx_t_pair(within_ra,13)', ((1/2)^(1/7)).^(dist-ra) .* vertidx_t_pair(within_decay,13)']));
            %               %V(all_vert_idx,1) = 0;
            %               V(all_vert_idx,1:12) = 0; % If no within-radius and within-decay contact, then the value is 0
            if isempty(dist)% If there is, here we used the average of all the activity in one vertex, which is subject to change
                V(all_vert_idx) = 0;
                %V(all_vert_idx,1:12) = mean(vertidx_t_pair(within_ra,2:13),1);
            else
                %V(all_vert_idx,1) = mean([vertidx_t_pair(within_ra,13)', ((1/2)^(1/7)).^(dist-ra) .* vertidx_t_pair(within_decay,13)']);
                %V(all_vert_idx,1:12) = mean([vertidx_t_pair(within_ra,2:13); repmat((((1/2)^(1/7)).^(dist-ra))',1,12) .* vertidx_t_pair(within_decay,2:13)],1);
                %mean of linear decay of activity
                weight = 1-((ddecay-dist)./(ddecay-ra));
                V(all_vert_idx) = mean(weight.*activity(within_decay));
            end
        end
        
        cv = find(V>0); % find non-zero rows of V and return the value;
        c_range = [-2,15];
        clmp = jet;
        color_inds = [];
        for vv=1:length(cv)
            color_pctile = min((V(cv(vv)) - c_range(1))/(c_range(2)-c_range(1)),1) ;
            color_inds(cv(vv)) = min(floor(color_pctile * 64), 1);
        end
        color_inds(color_inds == 0) = 1;
        Hp = patch('vertices',cortex.vert(cv,:),'faces',cortex.tri(cv,:),'FaceVertexCData', clmp(color_inds,:),'edgecolor','none','FaceColor','interp');
                        
        %         for type_idx = 1:size(V,2);
        %             V_color = 1*ones(length(BS1.Vertices),3);
        %             for i = 1:length(V_color);
        %                 if V(i,type_idx) == 0;
        %                 else
        %                     color_pctile = min((V(i,type_idx) - color_range(1))/(color_range(2)-color_range(1)),1);
        %                     V_color(i,:) = clmp(max(round(length(clmp) * color_pctile),1),:);
        %                 end
        %             end
        %             % this is used to hide unrelavent regions
        %             V_color(roi_index_total,:) = ones(length(roi_index_total),3);
        %
        %             figure (type_idx);
        %             Hp = patch('vertices',BS1.Vertices,'faces',BS1.Faces,'FaceVertexCData', V_color,'edgecolor','none','FaceColor','interp');%,...
        %                 %'facelighting', 'gouraud', 'specularstrength', 0, 'ambientstrength', 0.5, 'diffusestrength', 0.5);
        %             axis equal
        %             camlight('headlight','infinite');
        %                         set(gca,'CameraPosition',DispCamPos1.cp,...
        %                     'CameraTarget',DispCamPos1.ct,...
        %                     'CameraViewAngle',DispCamPos1.cva,...
        %                     'CameraUpVector',DispCamPos1.uv);
        %             axis off;
        %             %saveas(figure (type_idx),[save_fig_dir,filesep,'Projection_PD_',band{round(type_idx/2)},'_',cond{mod(type_idx,2)+1},'_rm20062011'],'fig');
    end
end

