function [artifact]=auto_reject2(signal,events,fs)
% function [artifact]=auto_reject2(signal,events,fs)
%
% Input - signal: 2D time x channel, in either order
% events - if N x 1, each of N events is the start of a trial, and the time 
%          period between events is used.
%          If N x 2, each N is a beginning and end of a trial
%          Event times are specified in seconds
% fs - sampling rate in Hz

if size(signal,1)>size(signal,2)
    signal=signal';
end
nch=size(signal,1);
nt=size(events,1);
events=round(events*fs);
trials=cell(nt,1);

if size(events,2) == 1
    for t=1:nt-1
        trials{t}=signal(:,events(t):events(t+1));
    end
    try
        trials{nt}=signal(:,events(nt):events(nt)+round(mean(diff(events))));
    catch
        trials{nt}=signal(:,events(nt):events(nt)+round(5*fs));
    end
else
   for t=1:nt
       trials{t} = signal(:, events(t,1):events(t,2));
   end
end

dtrials=cellfun(@(x) max(abs(diff(x,1,2)),[],2),trials,'Uni',0); %maximum single sample difference in each trial
dtrials=cat(2,dtrials{:}); %ch x trials, max single sample difference
dm = mean(dtrials,2); % mean max diff over trials
ds = std(dtrials,0,2); % std max diff over trials

gain = cellfun(@(x) nanmean(abs(diff(x,1,2)), 2),trials,'Uni',0);
gain = cat(2,gain{:});
gm = mean(gain,2);
gs = std(gain, 0,2);

maxVol=cellfun(@(x) max(abs(x),[],2),trials,'UniformOutput',false); 
maxVol=cat(2,maxVol{:}); % maximum amp sample, ch x trial
m=mean(maxVol,2); % mean max
s=std(maxVol,0,2); % std max
for i=1:nch
    % finding the 
    artifact{i}=unique([find(maxVol(i,:)>m(i)+5*s(i)) find(dtrials(i,:) > dm(i)+5*ds(i)) find(dtrials(i,:)./gain(i,:) > 30)]);    
end

end