function snrVoice = computeLoudnessRMS(audiofile)
%Loudness comparison between baseline and speech

pb=0;
if pb
    figure;
end

load(audiofile);
for tr = 1:length(trials.SpOnset)
    baselineStart = round((trials.BaseBack(tr) - 0.5)*Afs);
    baselineEnd = round((trials.BaseBack(tr))*Afs);
    spStart = round(trials.SpOnset(tr)*Afs);
    if ~isnan(trials.SpEnd(tr))
        spEnd = round(trials.SpEnd(tr)*Afs);
    else 
        spEnd = length(Audio);
    end
    rmsVoice(tr) = rms(Audio(spStart:spEnd));
    if ~sum(tr == trials.BaseRejectNoise)  %check to see that we haven't noise rejected trial  
        rmsBase(tr) = rms(Audio(baselineStart:baselineEnd));
    else
        rmsBase(tr) = NaN;
    end
    
    if pb
        plot(baselineStart:baselineEnd, Audio(baselineStart:baselineEnd));
        hold on;
        plot(spStart:spEnd, Audio(spStart:spEnd), 'r');
    end
end
snrVoice = rmsVoice./rmsBase;

