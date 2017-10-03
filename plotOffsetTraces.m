function plotOffsetTraces(signal, fs, offset)

if size(signal,2) > size(signal,1)
    signal = signal';
end
nt = size(signal,2);
time = ((1:size(signal,1))-1) / fs; 

meanstd = mean(nanstd(signal,0,1));

figure; hold on;
for ii=1:nt
    plot(time, signal(:,ii)./(meanstd*4) - (ii), 'LineWidth',1);
end