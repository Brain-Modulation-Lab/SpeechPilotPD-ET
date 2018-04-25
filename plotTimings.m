% script code highlighting time periods of pre-stim, and, stim-response

figure;
nt = trials.nTrials;
for ii=1:nt
    pre = [trials.BaseBack(ii)-.5, trials.BaseBack(ii), trials.BaseBack(ii), trials.BaseBack(ii)-.5];
    post = [trials.CommandStim(ii), trials.SpOnset(ii), trials.SpOnset(ii), trials.CommandStim(ii)];
    fill(pre, [0 0 1 1], [1 0 0]); %shape of baseline
    hold on;
    fill(post,[0 0 1 1], [0 0 1]); %cue to speech
end