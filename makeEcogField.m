% This is to make an field named 'Ecog' in the preprocessed data folder for
% those subjects who don't currently have them.
% PWJ 06/12/2017

subjectLists; %load lists of subjects
subjects = PD_subjects;
%codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';

%basedir = '/Volumes/ToughGuy/RichardsonLabData/ET';
basedir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
%basedir='/Volumes/Nexus/Electrophysiology_Data/DBS_Intraop_Recordings';
%%
for s=1:length(subjects)
    subjDir = [basedir filesep subjects{s} filesep 'Preprocessed Data'];
    tmp=dir([subjDir filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep 'DBS*.mat']);
    
    for ii=1:length(tmp)
        data=load([subjDir filesep tmp(ii).name]);
%         if ~isfield(data, 'Ecog')
%             ecogi = strncmp('Strip', data.labels, 5);
%             data.Ecog = data.filt(:,ecogi);
%             data.EcogLabels = data.labels(ecogi);
%             %data.labels = data.labels(~ecogi);
%             %data.filt = data.filt(:,~ecogi);
%             
%             save([subjDir filesep tmp(ii).name], '-struct', 'data');
%         end
        changed = 0;
        if ~isfield(data, 'SubjectID')
            name = strtok(tmp(ii).name, '_');
            data.SubjectID = name;
            changed = 1;
        end
        if ~isfield(data, 'Side')
            sidecell = cell2mat(data.side);
            if strcmpi(sidecell(1), 'L')
                data.Side = 'Left';
            else
                data.Side = 'Right';
            end
            changed=1;
        end
        if changed
            save([subjDir filesep tmp(ii).name], '-struct', 'data');
        end
    end
end