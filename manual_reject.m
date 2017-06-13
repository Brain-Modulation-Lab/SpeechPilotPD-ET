function [badtrials]=manual_reject(signal,events,fs)

if size(signal,1)>size(signal,2)    
    signal=signal';
end
events=round(events*fs);
nt=length(events);
trials=cell(length(events)-1,1);

for t=1:nt-1
trials{t}=signal(:,events(t):events(t+1));
end
trials{nt}=signal(:,events(nt):events(nt)+round(mean(diff(events))));
x=cumsum(cellfun(@(x) size(x,2),trials));
y=cellfun(@num2str,num2cell(1:nt),'UniformOutput',false);
for i=1:nt
tmp.event(i).type=num2str(y{i});
tmp.event(i).latency=x(i);
end
eegplot(cat(2,trials{:}),'srate',fs,'events',tmp.event,'winlength',30)
h = findobj('tag', 'EEGPLOT');
waitfor(h);
x = inputdlg('Enter space-separated bad trials:',...
             'Sample', [1 50]);
badtrials = str2num(x{:});
% for i=1:length(E)
% eegplot(trials{i},'srate',fs,'title',num2str(i),'winlength',(tend(i)-tstart(i))/fs,'events',E{i}.event)
% w(i)=waitforbuttonpress;
% h = findobj('tag', 'EEGPLOT');
% close(h)
% end
w=[];
end