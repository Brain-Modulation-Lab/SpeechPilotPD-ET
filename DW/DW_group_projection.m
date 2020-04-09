% This script used to project activity to MNI brain for PD-ET project
machine = input('Please specify mac(1) or linux(2): '); % specify the machine

% load in cortex and loc-activity pair
if machine == 1
    load('/Volumes/Nexus/Users/dwang/Gamma_activatiom/datafiles/video_data/DispCamPos1');    
    load('/Volumes/Nexus/Users/dwang/ET-PD/datafiles/loc_activity_pair_t_PD.mat');
    addpath('/Applications/MATLAB_R2017b.app/toolbox/map/map') % Add extractfield function to path
    load('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/mni/cortex_MNI.mat');
    save_fig_dir = '/Volumes/Nexus/Users/dwang/ET-PD/Results/Figures/group plotting';
    
else
    load('/media/dionysis/Users/dwang/Gamma_activatiom/datafiles/video_data/DispCamPos1');
    load('/media/dionysis/Users/dwang/ET-PD/datafiles/loc_activity_pair_t_PD.mat');
    load('/media/dionysis/Users/dwang/Group_plotting/datafiles/mni/cortex_MNI.mat');
    save_fig_dir = '/media/dionysis/Users/dwang/ET-PD/Results/Figures/group plotting';
end

% remove DBS2006
%loc_activity_pair(69:96) = [];
%remove 2006 and 2011
loc_activity_pair([69:96,245:272]) = [];

for i = 1:length(loc_activity_pair);
    vertidx_t_pair(i,1) = loc_activity_pair(i).vertex_idx; % first column is vertex index
    if isnan(loc_activity_pair(i).BroadbandGamma)
        vertidx_t_pair(i,2:13) = NaN;
    else
        vertidx_t_pair(i,2:3) = loc_activity_pair(i).alpha;
        vertidx_t_pair(i,4:5) = loc_activity_pair(i).beta2;
        vertidx_t_pair(i,6:7) = loc_activity_pair(i).beta1;
        vertidx_t_pair(i,8:9) = loc_activity_pair(i).Hgamma;
        vertidx_t_pair(i,10:11) = loc_activity_pair(i).Gamma;
        vertidx_t_pair(i,12:13) = loc_activity_pair(i).BroadbandGamma;
    end
end
% column 2-13 is activity of the vertex

vertidx_t_pair_ynan = vertidx_t_pair;
vertidx_t_pair(find(isnan(vertidx_t_pair(:,13))),:) = []; %get vertex index-activity paired, remove nan

%order:cue, onset; alpha,beta2,beta1,Hgamma,Gamma,BroadbandGamma
ra = 3; % radius of full activity, subject to change
ddecay = 10; % decay distance, subject to change


V = [];
for all_vert_idx = 1:length(BS1.Vertices);
    all_vert_idx
   
   % for each vertex, find if it's within radius of any contact 
   within_ra = find(pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(:,1),:))<=ra);
   %for each vertex, find if it's within decay of any contact
   within_decay = find(pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(:,1),:))>ra & ...
       pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(:,1),:)) <= ddecay);
   dist = pdist2(BS1.Vertices(all_vert_idx,:),BS1.Vertices(vertidx_t_pair(within_decay,1),:));
   % get the distance between current vertex and within-decay contacts
   
   
  
  if isempty(max([vertidx_t_pair(within_ra,13)', ((1/2)^(1/7)).^(dist-ra) .* vertidx_t_pair(within_decay,13)']));
      %V(all_vert_idx,1) = 0;
      V(all_vert_idx,1:12) = 0; % If no within-radius and within-decay contact, then the value is 0
  elseif isempty(dist);% If there is, here we used the average of all the activity in one vertex, which is subject to change
      V(all_vert_idx,1:12) = mean(vertidx_t_pair(within_ra,2:13),1);
  else
      %V(all_vert_idx,1) = mean([vertidx_t_pair(within_ra,13)', ((1/2)^(1/7)).^(dist-ra) .* vertidx_t_pair(within_decay,13)']);
      
      V(all_vert_idx,1:12) = mean([vertidx_t_pair(within_ra,2:13); repmat((((1/2)^(1/7)).^(dist-ra))',1,12) .* vertidx_t_pair(within_decay,2:13)],1);
  end
end
colored_V_allband = V(find(any(V,2)),:); % find non-zero rows of V and return the value;
%colored_V = V(find(V~=0)); % find non-zero rows of V and return the value;


% determine color range
all_val = colored_V_allband(:);

color_range = [-7.5,10];
clmp = jet;


band = {'alpha','beta2','beta1','Hgamma','Gamma','BroadbandGamma'};
cond = {'Onset','Cue'};
for type_idx = 1:size(V,2);
    
    V_color = 1*ones(length(BS1.Vertices),3);

    for i = 1:length(V_color);
        if V(i,type_idx) == 0;
        else
            color_pctile = min((V(i,type_idx) - color_range(1))/(color_range(2)-color_range(1)),1);
            V_color(i,:) = clmp(max(round(length(clmp) * color_pctile),1),:);
        end
    end
    % this is used to hide unrelavent regions
    V_color(roi_index_total,:) = ones(length(roi_index_total),3);

    figure (type_idx);
    Hp = patch('vertices',BS1.Vertices,'faces',BS1.Faces,'FaceVertexCData', V_color,'edgecolor','none','FaceColor','interp');%,...
        %'facelighting', 'gouraud', 'specularstrength', 0, 'ambientstrength', 0.5, 'diffusestrength', 0.5);
    axis equal
    camlight('headlight','infinite');
                set(gca,'CameraPosition',DispCamPos1.cp,...
            'CameraTarget',DispCamPos1.ct,...
            'CameraViewAngle',DispCamPos1.cva,...
            'CameraUpVector',DispCamPos1.uv);
    axis off;
    %saveas(figure (type_idx),[save_fig_dir,filesep,'Projection_PD_',band{round(type_idx/2)},'_',cond{mod(type_idx,2)+1},'_rm20062011'],'fig');
end

