function [latency, duration, commandT] = responseTimingsFromCodingFile(fname, Audio, Afs, CodingMatrix, EventTimes, SkipEvents)

pb = 1;
maxTrial = 120;
% Row 5 is marked Speech Onset, Row 6 is Speech Offset
% Just get the first 60 trials - consistent with the rest of the analysis
% for pilot data
commandi = SkipEvents + 4:4:length(EventTimes); 
commandi = commandi(1:maxTrial);
commandT = EventTimes(commandi);

SpOnLat = CodingMatrix(5, 1:maxTrial);
SpOffLat = CodingMatrix(6,1:maxTrial);
onset = cellfun(@(x) nancheck(x), SpOnLat);
offset = cellfun(@(x) nancheck(x), SpOffLat);
duration = offset-onset;
latency = onset;

if pb
    figure;
    plot(Audio, 'k');
    hold on;
    plot([commandT; commandT]*Afs, 1000*[-ones(1,maxTrial); ones(1, maxTrial)],'r-');
    for ii=1:maxTrial
        if ~isnan(onset(ii)) && ~isnan(offset(ii))
            spI = round(Afs*(commandT(ii)+onset(ii))):round(Afs*(commandT(ii)+offset(ii)));
            plot(spI, Audio(spI), 'b-')
        end
    end
    xlim([commandT(1)*Afs - Afs, (commandT(10) + offset(10) + .5)*Afs]);
    ylim([min(Audio), max(Audio)]);
    title(fname);
end