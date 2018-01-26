%Simulate RT analysis

rt = poissrnd(450, 60,1)+450;

noise = 200;
sp_rho = [0 .1 .25 .5 .75 1];
cue_rho = 1;
shift = -100;

for ii = 1:length(sp_rho)
    onset = 2*mean([(sp_rho(ii).*rt)+1, cue_rho.*ones(60,1)]') + noise*rand(1,60) + shift;

    figure;
    [~, si] = sort(rt);
    plot(rt(si), 'or'); hold on;
    plot(onset(si), 'kx');

    CueR=onset';
    SPR=(rt - onset');

    [rhoC(ii),pC(ii)] = corr(rt, CueR)
    [rhoS(ii),pS(ii)] = corr(rt, SPR)
end