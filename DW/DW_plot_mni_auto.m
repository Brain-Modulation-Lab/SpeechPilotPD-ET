load('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/DBS2000_elec_idx.mat');
load('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/mni/cortex_MNI.mat');
load('/Volumes/Nexus/Users/dwang/Gamma_activatiom/datafiles/video_data/DispCamPos1');
id = {'01','02','03','04','06','07','08','09','10','11','13','14','15'};

for i = 1:length(DBS2000_elec_idx.patient_id);
    figure (i);hold on
    V = ones(length(BS1.Vertices),3); % initialize color matrix
    V(DBS2000_elec_idx.elec2mnicort_indx{i}(:,1),:) = repmat([1,0,0],length(DBS2000_elec_idx.elec2mnicort_indx{i}(:,1)),1);
    patch('vertices',BS1.Vertices,'faces',BS1.Faces,'FaceVertexCData',V,'edgecolor','none','FaceColor','interp');
    axis equal
    camlight('headlight','infinite');
    fh(1)=gcf;
    axis off;
            set(gca,'CameraPosition',DispCamPos1.cp,...
            'CameraTarget',DispCamPos1.ct,...
            'CameraViewAngle',DispCamPos1.cva,...
            'CameraUpVector',DispCamPos1.uv);
        alpha 0.7
        
        Dir_Elec = dir(['/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings/','DBS20',id{i},'/Anatomy/FreeSurfer/*/Electrode_locations/Final/*_MNI.mat']);
    load([Dir_Elec.folder,filesep,Dir_Elec.name]);
        elec = reshape(cell2mat(CortElecLoc_MNI),3,length(CortElecLoc_MNI))';
    plot3(elec(:,1), elec(:,2), elec(:,3), 'b.', 'MarkerSize', 15);
    %saveas(figure (i),['/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings/Localization Figures/','DBS20',id{i},'/Strip_DBS20',id{i},'_MNI'],'fig');
        
end

% plot and project all to one brain
figure (1); hold on;
V = ones(length(BS1.Vertices),3); % initialize color matrix;
vert_idx = [];
for i = 1:13;
    vert_idx = [vert_idx;DBS2000_elec_idx.elec2mnicort_indx{i}(:,1)];
end

vert_idx = unique(vert_idx);
vert_idx =sort(vert_idx);
V(vert_idx,:) = repmat([1,0,0],length(vert_idx),1);
patch('vertices',BS1.Vertices,'faces',BS1.Faces,'FaceVertexCData',V,'edgecolor','none','FaceColor','interp');
    axis equal
    camlight('headlight','infinite');
    fh(1)=gcf;
    axis off;
            set(gca,'CameraPosition',DispCamPos1.cp,...
            'CameraTarget',DispCamPos1.ct,...
            'CameraViewAngle',DispCamPos1.cva,...
            'CameraUpVector',DispCamPos1.uv);

for i = 1:length(DBS2000_elec_idx.patient_id);
    Dir_Elec = dir(['/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings/','DBS20',id{i},'/Anatomy/FreeSurfer/*/Electrode_locations/Final/*_MNI.mat']);
        load([Dir_Elec.folder,filesep,Dir_Elec.name]);
            elec = reshape(cell2mat(CortElecLoc_MNI),3,length(CortElecLoc_MNI))';
        plot3(elec(:,1), elec(:,2), elec(:,3), 'b.', 'MarkerSize', 15);
end

alpha 0.7

    saveas(figure (1),'/Volumes/Nexus/Users/dwang/ET-PD/Results/Figures/group plotting/DBS2000_elec_plot+proj','fig');






% on pc

id = {'01','02','03','04','06','07','08','09','10','11','13','14','15'};

for i = 1:13;
        Dir_Elec = dir(['Z:\Electrophysiology_Data\DBS_Intraop_Recordings\','DBS20',id{i},'\Anatomy\FreeSurfer\*\Electrode_locations\Final\*_eq.mat']);
        load([Dir_Elec.folder,filesep,Dir_Elec.name]);
        elec = reshape(cell2mat(CortElecLoc),3,length(CortElecLoc))';
        
        Dir_indiv_cort = dir(['Z:\Electrophysiology_Data\DBS_Intraop_Recordings\','DBS20',id{i},'\Anatomy\FreeSurfer\*\cortex_indiv.mat']);
        load([Dir_indiv_cort.folder,filesep,Dir_indiv_cort.name]);
        figure (i); hold on;
        Hp = patch('vertices',cortex.vert,'faces',cortex.tri(:,[1 3 2]),...
    'facecolor',[.85 .50 .50],'edgecolor','none',...
    'facelighting', 'gouraud', 'specularstrength', .50);
    camlight('headlight','infinite');
    axis off; axis equal
    plot3(elec(:,1), elec(:,2), elec(:,3), 'b.', 'MarkerSize', 15);
    saveas(figure (i),['Z:\Electrophysiology_Data\DBS_Intraop_Recordings\Localization Figures\','DBS20',id{i},'\Strip_DBS20',id{i}],'fig');
        
end