% This script is used to plot atlas to MNI brain


% load MNI brain
coordDir = [savedDataDir filesep 'Population' filesep 'electrodeLocations' filesep 'MNI'];
load([coordDir filesep 'cortex_MNI.mat']);

atlas=2; % specify Desikan-Killiany atlas

V = zeros(length(BS1.Vertices),3); % initialize color matrix
for region=1:length(BS1.Atlas(atlas).Scouts)
V(BS1.Atlas(atlas).Scouts(region).Vertices,:) = repmat(BS1.Atlas(atlas).Scouts(region).Color,length(BS1.Atlas(atlas).Scouts(region).Vertices),1);
end


figure; patch('vertices',BS1.Vertices,'faces',BS1.Faces,'FaceVertexCData',V,'edgecolor','none','FaceColor','interp');
axis equal
camlight('headlight','infinite');
fh(1)=gcf;
axis off;




% prefrontal
roi = BS1.Atlas(2).Scouts([9,10,25:34,17,18]);

roi_idx = [];
for i = 1:length(roi);
    roi_idx = [roi_idx,roi(i).Vertices];
end


V = ones(length(BS1.Vertices),3); % initialize color matrix

V(roi_idx,:) = repmat([1,0,0],length(roi_idx),1);


%middle and inferior temporal gyrus
roi_2 = BS1.Atlas(2).Scouts([73:76]);

roi_2_idx = [];
for i = 1:length(roi_2);
    roi_2_idx = [roi_2_idx,roi_2(i).Vertices];
end



V = ones(length(BS1.Vertices),3); % initialize color matrix

V(roi_2_idx,:) = repmat([1,0,0],length(roi_2_idx),1);


roi_index_total = [roi_idx,roi_2_idx];


