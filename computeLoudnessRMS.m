%Loudness comparison between baseline and speech

figure;
for tr = 1:length(trials.SpOnset)
    baselineStart = round((trials.BaseBack(tr) - 0.5)*Afs);
    baselineEnd = round((trials.BaseBack(tr))*Afs);
    spStart = round(trials.SpOnset(tr)*Afs);
    spEnd = round(trials.SpEnd(tr)*Afs);
    rmsVoice(tr) = rms(Audio(spStart:spEnd));
    if ~sum(tr == trials.BaseRejectNoise)  %check to see that we haven't noise rejected trial  
        rmsBase(tr) = rms(Audio(baselineStart:baselineEnd));
    else
        rmsBase(tr) = NaN;
    end
    
    plot(baselineStart:baselineEnd, Audio(baselineStart:baselineEnd));
    hold on;
    plot(spStart:spEnd, Audio(spStart:spEnd), 'r');
end
snrVoice = rmsVoice./rmsBase;

