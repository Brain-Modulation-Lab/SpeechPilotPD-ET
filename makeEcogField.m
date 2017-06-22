% This is to make an field named 'Ecog' in the preprocessed data folder for
% those subjects who don't currently have them.
% PWJ 06/12/2017

%ET
subjects = {'DBS4038', 'DBS4040', 'DBS4046', 'DBS4047', 'DBS4049', 'DBS4051', 'DBS4053', 'DBS4054', 'DBS4055', 'DBS4056'};
%PD
subjects = {'DBS2001','DBS2002','DBS2003','DBS2004','DBS2005','DBS2006','DBS2007','DBS2008', ...
            'DBS2009','DBS2010','DBS2011','DBS2012','DBS2013','DBS2014','DBS2015'};

codeDir = '~pwjones/Documents/RichardsonLab/matlab/SpeechPilotPD-ET';

%basedir = '/Volumes/ToughGuy/RichardsonLabData/ET';
basedir='\\136.142.16.9\Nexus\Electrophysiology_Data\DBS_Intraop_Recordings';
%%
for s=1:length(subjects)
    subjDir = [basedir filesep subjects{s} filesep 'Preprocessed Data'];
    tmp=dir([subjDir filesep 'DBS*.mat']);
    %tmp = dir([datadir filesep 'DBS*.mat']);
    
    for ii=1:length(tmp)
        data=load([subjDir filesep tmp(ii).name]);
        if ~isfield(data, 'Ecog')
            ecogi = strncmp('Strip', data.labels, 5);
            data.Ecog = data.filt(:,ecogi);
            data.EcogLabels = data.labels(ecogi);
            %data.labels = data.labels(~ecogi);
            %data.filt = data.filt(:,~ecogi);
            
            save([subjDir filesep tmp(ii).name], '-struct', 'data');
        end
    end
end