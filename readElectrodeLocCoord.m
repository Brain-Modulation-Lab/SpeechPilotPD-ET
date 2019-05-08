%Read all of the ECoG electrode contact coordinates for a set of subjects

clear electrodePos
subjectLists;
group = 'ET';
subjects = eval([group '_subjects']); %variable contains the proper set

for ss = 1:length(subjects)
    COORD_PATH = fullfile(datadir, subjects{ss}, 'Anatomy','FreeSurfer','postop','Electrode_locations','Final');
    CortElecLoc = []; CortElecLoc_MNI = [];
    ind_file = dir([COORD_PATH filesep 'CortElecLoc*_eq.mat']);
    if ~isempty(ind_file)
        load([COORD_PATH filesep ind_file.name]);
    end
    
    MNI_file = dir([COORD_PATH filesep 'CortElecLoc*_MNI.mat']);
    if ~isempty(MNI_file)
        load([COORD_PATH filesep MNI_file.name]);
    end 
    electrodePos(ss).subject = subjects{ss};
    electrodePos(ss).IndCoord = CortElecLoc;
    electrodePos(ss).MNICoord= CortElecLoc_MNI;
end

