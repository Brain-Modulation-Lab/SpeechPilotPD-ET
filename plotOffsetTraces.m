function plotOffsetTraces(signal, fs, offset)

if size(signal,2) > size(signal,1)
    signal = signal';
end
nt = size(signal,2);
time = ((1:size(signal,1))-1) / fs; 

figure; hold on;
for ii=1:nt
    plot(time, signal(:,ii)-(ii-1)*offset, 'LineWidth',1);
end