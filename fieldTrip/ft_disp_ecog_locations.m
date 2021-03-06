% Plotting the electrode locations and eventually a mapping of activity

% load('Pop_ecog_ET_hgamma.mat');
% ETpd = popData;
% load('Pop_ecog_PD_hgamma.mat');
% PDpd = popData;

%BS1 structure
load([savedDataDir filesep 'population' filesep 'cortex_MNI.mat']);
%DispCamPos1 structure
load([savedDataDir filesep 'population' filesep 'DispCamPos1.mat']);

Ind_Gy_vert = [];
ind_region = [];
% only select gyrus
for i = 1:length(BS1.Atlas(2).Scouts); 
    if any(BS1.Atlas(2).Scouts(i).Label == 'G')
        ind_region = [ind_region,i];
        Ind_Gy_vert = [Ind_Gy_vert,BS1.Atlas(2).Scouts(i).Vertices];
    end    
end
Ind_Gy_vert = sort(Ind_Gy_vert);
Gyrus = BS1.Vertices(Ind_Gy_vert,:);

fh = figure(1); hold on;
Hp = patch('vertices',BS1.Vertices,'faces',BS1.Faces,...
'facecolor',[.85 .50 .50],'edgecolor','none',...
'facelighting', 'gouraud', 'specularstrength', .50);
camlight('headlight','infinite');
axis off; axis equal
set(gca,'CameraPosition',DispCamPos1.cp,'CameraTarget',DispCamPos1.ct,...
        'CameraViewAngle',DispCamPos1.cva, 'CameraUpVector',DispCamPos1.uv);
alpha 1
hold on;
    
%now get the electrode locations
clear mni_coord;
group = {'PD', 'ET'};
c = {[1 0 0], [0 0 1]};
for gg = 1:2
    gn = group{gg};
    eval(['pd = ' gn 'pd;']); %assigns population data struct to pd
    %mni_coord.(gn) = [];
    for ll=1:length(sd.loc_labels)
        ln = sd.loc_labels{ll};
        inc = sd.(gn).freq(1).loc(ll).include;
        coord = [];
        for ii=1:length(inc)
            coord = cat(1, coord, pd(ii).electrodeInfo.MNI_coord(inc{ii}, :));
        end
        mni_coord.(gn).(ln) = coord;
        [min_val,idx] = min(pdist2(coord,Gyrus),[],2);
        elec2mnicort_indx{ll}  = [Ind_Gy_vert(idx)',min_val];
        hold on;
        pcoord = BS1.Vertices(Ind_Gy_vert(idx),:);
        plot3(pcoord(:,1), pcoord(:,2), pcoord(:,3), '.', 'Color', c{gg},'MarkerSize', 15);
        %plot3(coord(:,1), coord(:,2), coord(:,3), 'b.', 'MarkerSize', 15);
        clear min_val idx;
        
    end    
end


