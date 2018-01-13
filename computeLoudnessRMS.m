function [snrVoice, rmsVoice, rmsBase] = computeLoudnessRMS(Audio, Afs, trials)
%Loudness comparison between baseline and speech

pb=1;
if pb
    figure;
    plot(Audio, 'k');
end

%load(audiofile);
rmsVoice = NaN*zeros(length(trials.SpOnset),1);
rmsBase = NaN*zeros(length(trials.SpOnset),1);
for tr = 1:length(trials.SpOnset)
    baselineStart = round((trials.BaseBack(tr) - 0.5)*Afs);
    baselineEnd = round((trials.BaseBack(tr))*Afs);
    spStart = round(trials.SpOnset(tr)*Afs);
    spEnd = round(trials.SpEnd(tr)*Afs);
    if ~isnan(spStart) && ~isnan(spEnd)
        rmsVoice(tr) = rms(Audio(spStart:spEnd));
    else
        rmsVoice(tr) = nan;
    end
    if ~sum(tr == trials.BaseRejectNoise)  %check to see that we haven't noise rejected trial  
        rmsBase(tr) = rms(Audio(baselineStart:baselineEnd));
    else
        rmsBase(tr) = NaN;
    end
    
    if pb && ~isnan(spEnd) && ~isnan(spStart)
        hold on;
        plot(baselineStart:baselineEnd, Audio(baselineStart:baselineEnd), 'b');
        plot(spStart:spEnd, Audio(spStart:spEnd), 'r');
    end
end
snrVoice = rmsVoice./rmsBase;

