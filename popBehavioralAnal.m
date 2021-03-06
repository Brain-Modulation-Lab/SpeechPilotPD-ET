% Analyze the reaction times of each session and the overall RTs
startup;
setDirectories;
load([savedDataDir filesep 'PD_populationBehavior.mat']);
nSessionsPD = length(sessionBehavior);
ET = load([savedDataDir filesep 'ET_populationBehavior.mat']);
sessionBehavior = [sessionBehavior ET.sessionBehavior];
nSessions = length(sessionBehavior);
PDsession = zeros(nSessions, 1);
PDsession(1:nSessionsPD) = 1;

allLatsM = NaN*zeros(60, nSessions);
allDurM = NaN*zeros(60, nSessions);
allSNRM = NaN*zeros(60, nSessions);
for ii=1:nSessions
    subj = strtok(sessionBehavior(ii).session, '_. ');
    %load([datadir filesep subj filesep 'Preprocessed Data' filesep sessionInfo(ii).name], 'trials');
    % now look at RTs
    lats = sessionBehavior(ii).SpLatency;
    allLatsM(:,ii) = lats(:);
    allDurM(:,ii) = sessionBehavior(ii).SpDuration;
    allSNRM(:,ii) = 20*log10(sessionBehavior(ii).snrVoice); %SNR db as in SLP matlab book
end

%% Reaction times
PDlat = [sessionBehavior(PDsession==1).SpLatency];
ETlat = [sessionBehavior(PDsession==0).SpLatency];
figure; 
edges = [0:0.1:5 Inf];
h2 = histogram(PDlat,edges); hold on;
h1 = histogram(ETlat, edges); 
h1.Normalization = 'probability'; h2.Normalization = 'probability';
h1.FaceColor = peteColorOrder{1}; h2.FaceColor = peteColorOrder{2}; 
legend({'PD', 'ET'});
PDmedian = nanmedian(PDlat);
ETmedian = nanmedian(ETlat);
plot([ETmedian ETmedian], [0 1], 'LineStyle', '--', 'Color', peteColorOrder{1});
text(PDmedian, .16, ['PD=' num2str(PDmedian, 3)]);
plot([PDmedian PDmedian], [0 1], 'LineStyle', '--', 'Color', peteColorOrder{2});
text(ETmedian, .15, ['ET=' num2str(ETmedian, 3)]);
ylim([0 .17]);
xlim([0 5.2]);
xlabel('Speech Onset Latency (sec)');
ylabel('Proportion of Responses');
set(gcf, 'Renderer', 'Painters');
disp('Reaction Time Wilcoxon Rank Sum')
[p,h] = ranksum(ETlat, PDlat)

%% Speech Duration
PDdur = [sessionBehavior(PDsession==1).SpDuration];
ETdur = [sessionBehavior(PDsession==0).SpDuration];
figure; 
edges = [0:0.1:1.5 Inf];
h2 = histogram(PDdur,edges); hold on;
h1 = histogram(ETdur, edges); 
h1.Normalization = 'probability'; h2.Normalization = 'probability';
h1.FaceColor = peteColorOrder{1}; h2.FaceColor = peteColorOrder{2}; 
legend({'PD', 'ET'});
PDmedian = nanmedian(PDdur);
ETmedian = nanmedian(ETdur);
plot([ETmedian ETmedian], [0 1], 'LineStyle', '--', 'Color', peteColorOrder{1});
text(PDmedian, .3, ['PD=' num2str(PDmedian, 3)]);
plot([PDmedian PDmedian], [0 1], 'LineStyle', '--', 'Color', peteColorOrder{2});
text(ETmedian, .32, ['ET=' num2str(ETmedian, 3)]);
ylim([0 .35]);
xlim([0 1.6]);
xlabel('Speech Duration (sec)');
ylabel('Proportion of Responses');
set(gcf, 'Renderer', 'Painters');
disp('Speech Duration Wilcoxon Rank Sum')
[p,h] = ranksum(ETdur, PDdur)

%% Load in the Formant analysis
% inconsistent in format between ET and PD datasets, but computed in the same way 
readETformantXLS;
ET_formantratio = [formantfreqs.iu_ratio];
PDformantfreqs = readPDformantXLS();
PD_formantratio = [PDformantfreqs.iu_ratio];
formantratio = [PD_formantratio ET_formantratio];
[ratios_sorted,sorti] = sort(formantratio);
PDlabel = zeros(length(formantratio),1); 
PDlabel(1:length(PD_formantratio)) = 1;
PDlabel_sort = PDlabel(sorti);
names = [{PDformantfreqs.subject} {formantfreqs.subject}];

figure;
boxplot(ratios_sorted, PDlabel_sort);
xlabel({'ET', 'PD'});

figure;
plot(1:length(formantratio), formantratio(sorti), 'o'); hold on;
plot(find(logical(PDlabel_sort)), ratios_sorted(logical(PDlabel_sort)), 'ro');
ah = gca;
xticks(ah, 1:length(formantratio));
xticklabels(ah, names(sorti)); xtickangle(90);
ylabel('Formant Centralization Ratio');

% Are the formant ratios correlated with any of the other behavioral
% measures?
ETsnr = allSNRM(:,PDsession == 0);
meanETsnr = nanmean(ETsnr, 1);
figure; plot(meanETsnr, ET_formantratio, 'o');
figure; plot(nanmean(allSNRM), formantratio, 'o'); 
xlabel('SNR RMS');
ylabel('Formant Centralization Ratio');
meanSNRM = nanmean(allSNRM);
sel = ~isinf(meanSNRM); 
[rho, pval] = corr(meanSNRM(sel)', formantratio(sel)');
% Correlate with response latency
seshLats = nanmedian(allLatsM);
[rho,pval] = corr(seshLats', formantratio')
figure; plot(seshLats, formantratio,'o');
xlabel('Median Session Latency'); ylabel('Formant Ratio');

%% Box plots comparing two groups
figure;
boxplot(allLatsM, PDsession, 'notch', 'on'); title('Response Latencies by Session');
figure;
boxplot(allDurM, PDsession, 'notch', 'on');  title('Response Duration by Session');
figure;
boxplot(allSNRM, PDsession, 'notch', 'on');  title('Voice RMS SNR by session');

%% Box plots with one for each session
figure;
boxplot(allLatsM); title('Response Latencies by Session');
figure;
boxplot(allDurM);  title('Response Duration by Session');
figure;
boxplot(allSNRM);  title('Voice RMS SNR by session');

