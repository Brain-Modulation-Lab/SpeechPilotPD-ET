subjects = {'DBS4038', 'DBS4040', 'DBS4046', 'DBS4047'};

codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';

basedir = '/Volumes/ToughGuy/RichardsonLabData/ET';
%datadir='\\136.142.76.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
%%
for s=1:length(subjects)
    subjDir = [basedir filesep subjects{s} filesep 'Preprocessed Data'];
    tmp=dir([subjDir filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep 'DBS*.mat']);
    
    for ii=1:length(tmp)
        data=load([datadir filesep tmp(ii).name]);
        if ~isfield(data, 'Ecog')
            ecogi = strncmp('Strip', data.labels, 5);
            data.Ecog = data.filt(:,ecogi);
            data.EcogLabels = data.labels(ecogi);
            data.labels = data.labels(~ecogi);
            data.filt = data.filt(:,~ecogi);
            
            save([datadir filesep tmp(ii).name], '-struct', 'data');
        end
    end
end