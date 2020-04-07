% This is derived from:
% /Users/Dengyu/Dropbox (Brain Modulation Lab)/Functions/Dengyu/MNI transformation/DW_plot_group_elec.m

%load('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/mni/cortex_MNI.mat');
id = {'38','40','43','46','47','49','51','52','53','54','55','56'};
%load('/Volumes/Nexus/Users/dwang/Gamma_activatiom/datafiles/video_data/DispCamPos1.mat');
load([savedDataDir filesep 'population' filesep 'cortex_MNI.mat']);

figure (1); hold on;
Hp = patch('vertices',BS1.Vertices,'faces',BS1.Faces,...
'facecolor',[.85 .50 .50],'edgecolor','none',...
'facelighting', 'gouraud', 'specularstrength', .50);
camlight('headlight','infinite');
axis off; axis equal
    set(gca,'CameraPosition',DispCamPos1.cp,...
            'CameraTarget',DispCamPos1.ct,...
            'CameraViewAngle',DispCamPos1.cva,...
            'CameraUpVector',DispCamPos1.uv);
    alpha 0.5

for i = 1:length(id);
    Dir_Elec = dir(['/Volumes/Nexus/DBS/','DBS40',id{i},'/Anatomy/FreeSurfer/*/Electrode_locations/Final/*_MNI.mat']);
    load([Dir_Elec.folder,filesep,Dir_Elec.name]);

    elec = reshape(cell2mat(CortElecLoc_MNI),3,length(CortElecLoc_MNI))';
    figure (1); hold on; plot3(elec(:,1), elec(:,2), elec(:,3), 'b.', 'MarkerSize', 15);
end