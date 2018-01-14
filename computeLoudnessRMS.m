function [snrVoice, rmsVoice, rmsBase] = computeLoudnessRMS(Audio, Afs, lat, dur, commandT)
%Loudness comparison between baseline and speech

pb=1;
if pb
    figure;
    plot(Audio, 'k');
end
nTrials = length(lat);
rmsVoice = NaN*zeros(nTrials,1);
rmsBase = NaN*zeros(nTrials,1);
for tr = 1:nTrials
    baselineStart = round((commandT(tr)-0.5)*Afs);
    baselineEnd = round(commandT(tr)*Afs);
    spStart = round((commandT(tr)+lat(tr))*Afs);
    spEnd = round((commandT(tr)+lat(tr)+dur(tr))*Afs);
    if ~isnan(spStart) && ~isnan(spEnd)
        rmsVoice(tr) = rms(Audio(spStart:spEnd));
    else
        rmsVoice(tr) = nan;
    end
    rmsBase(tr) = rms(Audio(baselineStart:baselineEnd));
%     if ~sum(tr == trials.BaseRejectNoise)  %check to see that we haven't noise rejected trial  
%         rmsBase(tr) = rms(Audio(baselineStart:baselineEnd));
%     else
%         rmsBase(tr) = NaN;
%     end
    
    if pb && ~isnan(spEnd) && ~isnan(spStart)
        hold on;
        plot(baselineStart:baselineEnd, Audio(baselineStart:baselineEnd), 'b');
        plot(spStart:spEnd, Audio(spStart:spEnd), 'r');
    end
end
snrVoice = rmsVoice./rmsBase;

