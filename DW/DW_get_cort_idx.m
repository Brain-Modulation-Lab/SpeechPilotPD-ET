% This script projects MNI electrodes to MNI cortex vertexes and get the
% vertex indexes


load([savedDataDir filesep 'population' filesep 'cortex_MNI.mat']);
%load('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/mni/cortex_MNI.mat');
id = {'01','02','03','04','06','07','08','09','10','11','13','14','15'};


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

for i = 1:length(id);
    Dir_Elec = dir(['/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings/','DBS20',id{i},'/Anatomy/FreeSurfer/*/Electrode_locations/Final/*_MNI.mat']);
    
    load([Dir_Elec.folder,filesep,Dir_Elec.name]);
    [min_val,idx] = min(pdist2(cell2mat(CortElecLoc_MNI'),Gyrus),[],2);
    elec2mnicort_indx{i}  = [Ind_Gy_vert(idx)',min_val];
    clear min_val idx CortElecLoc_MNI
end

DBS2000_elec_idx.elec2mnicort_indx = elec2mnicort_indx;

DBS2000_elec_idx.patient_id = id;

%save('/Volumes/Nexus/Users/dwang/Group_plotting/datafiles/DBS2000_elec_idx1','DBS2000_elec_idx');

fh = figure(1); hold on;
Hp = patch('vertices',BS1.Vertices,'faces',BS1.Faces,...
'facecolor',[.85 .50 .50],'edgecolor','none',...
'facelighting', 'gouraud', 'specularstrength', .50);
camlight('headlight','infinite');
axis off; axis equal
set(gca,'CameraPosition',DispCamPos1.cp,'CameraTarget',DispCamPos1.ct,...
        'CameraViewAngle',DispCamPos1.cva, 'CameraUpVector',DispCamPos1.uv);
alpha 0.7
hold on;






    

