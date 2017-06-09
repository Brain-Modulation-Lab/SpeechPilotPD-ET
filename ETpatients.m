% Defining the location for the ET patient's data
ET_patients = {'DBS4038', 'DBS4040', 'DBS4043', 'DBS4046', ...
                'DBS4047', 'DBS4049', 'DBS4051', 'DBS4053', ...
                'DBS4054', 'DBS4055', 'DBS4056'};
WordLists = cell(length(ET_patients));

WordLists{1} = [1, 2, 3, 4];
WordLists{2} = [2, 1];
WordLists{3} = [1,2];
WordLists{4} = [1,2,3];
WordLists{5} = [1,2,3];
WordLists{6} = [1,2];
WordLists{7} = [1,2];
WordLists{8} = [1,2];
WordLists{9} = [1,2];
WordLists{10} = [1,2];
WordLists{11} = [1,2];

dataroot = '/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings';


