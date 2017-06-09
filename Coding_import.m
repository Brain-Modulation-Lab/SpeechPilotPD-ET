rootdr='/home/richardsonlab/Dropbox/Speech_Task/';
root2='/home/richardsonlab/Dropbox/Speech_Project/Decoding/coding_files/';
load(['/home/richardsonlab/Dropbox/Speech_Project/Decoding/DecodingAnalysis/SpeechTrials.mat'], 'SpeechTrials')
index=SpeechTrials(:,1);

FW={'daif','dight','deave','dipe'};

sid=fn(1:8);    
tind=~cellfun(@isempty,strfind(index,sid));
tmp=SpeechTrials(tind,:);   
tmp(cellfun(@isempty, tmp(:,12)),12)={NaN};
tmp(cellfun(@isempty, tmp(:,13)),13)={NaN};

WL1=find(strcmp(FW(str2num(fn(end-3))),tmp(:,5) ));   
data=load(fn);

tr=tmp(WL1:WL1+59,:);
Audio=data.Audio;
Asr=data.Asr;

audioM=mean(Audio);
audioS=std(Audio);

trials.SpOnset=data.CommandStim(1:60)'+cellfun(@double, tr(:,12));
trials.SpEnd=data.CommandStim(1:60)'+cellfun(@double, tr(:,13));
trials.BaseBack=data.CommandStim(1:60)';
trials.BaseFwd=[data.EventTimes(1); data.FeedbackStim(1:59)'];

trials.BaseRejectNoise=find(cell2mat(arrayfun(@(x,y) any(Audio(round(x*Asr):round(y*Asr))>(audioM+ 5*audioS)),trials.BaseFwd,trials.BaseBack,'UniformOutput',0)));
trials.BaseRejectSpk=find(data.FeedbackStim(1:60)'-trials.SpEnd <0);
trials.coding=tr;



figure
A=downsample(data.Audio,10);
plot((1:length(A))/(Asr/10),A)
hold on; plot(trials.SpOnset*[1 1], ylim, 'r');
hold on; plot(trials.SpEnd*[1 1], ylim, 'g');
hold on; plot(trials.BaseBack*[1 1], ylim, 'c');
hold on; plot(trials.BaseFwd*[1 1], ylim, 'b');
hold on;arrayfun(@(x) text(double(trials.BaseFwd(x)),sum(abs(ylim))/2,num2str(x)),1:60)

save([fn '.mat'],'trials','-append')
save([root2 tr{1}],'trials','-append')
clearvars Audio trials data tr 

cd([rootdr]) 



%%
rootdr='/home/richardsonlab/Dropbox/Speech_Task/';
root2='/home/richardsonlab/Dropbox/Speech_Project/Decoding/coding_files/';
load(['/home/richardsonlab/Dropbox/Speech_Project/Decoding/DecodingAnalysis/SpeechTrials.mat'], 'SpeechTrials')
index=SpeechTrials(:,1);
subjs=dir('*');
FW={'daif','dight','deave','dipe'};
for s=1:length(subjs)
sid=subjs(s).name;    
tind=~cellfun(@isempty,strfind(index,sid));
tmp=SpeechTrials(tind,:);   
cd([rootdr sid]) 
 files=dir('*.mat');
 side=files(1).name(end-5:end-4);
 tmp(cellfun(@isempty, tmp(:,12)),12)={NaN};
tmp(cellfun(@isempty, tmp(:,13)),13)={NaN};
for w =1:length(files)
 
WL1=find(strcmp(FW(str2num(files(w).name(end-7))),tmp(:,5) ));   

data=load(files(w).name);

tr=tmp(WL1:WL1+59,:);
% audio=load([root2 tr{1}]);

     Audio=data.Audio;
     Asr=data.Asr;
%      save(files(w).name,'Audio','Asr','-append');


audioM=mean(Audio);
audioS=std(Audio);

trials.SpOnset=data.CommandStim(1:60)'+cellfun(@double, tr(:,12));
trials.SpEnd=data.CommandStim(1:60)'+cellfun(@double, tr(:,13));
trials.BaseBack=data.CommandStim(1:60)';
trials.BaseFwd=[data.EventTimes(1); data.FeedbackStim(1:59)'];

trials.BaseRejectNoise=find(cell2mat(arrayfun(@(x,y) any(Audio(round(x*Asr):round(y*Asr))>(audioM+ 5*audioS)),trials.BaseFwd,trials.BaseBack,'UniformOutput',0)));
trials.BaseRejectSpk=find(data.FeedbackStim(1:60)'-trials.SpEnd <0);
trials.coding=tr;



figure
A=downsample(data.Audio,10);
plot((1:length(A))/(Asr/10),A)
hold on; plot(trials.SpOnset*[1 1], ylim, 'r');
hold on; plot(trials.SpEnd*[1 1], ylim, 'g');
hold on; plot(trials.BaseBack*[1 1], ylim, 'c');
hold on; plot(trials.BaseFwd*[1 1], ylim, 'b');
hold on;arrayfun(@(x) text(trials.BaseFwd(x),sum(abs(ylim))/2,num2str(x)),1:60)

save(files(w).name,'trials','-append')
save([root2 tr{1}],'trials','-append')
clearvars Audio trials data tr 
end
cd([rootdr]) 
 
end