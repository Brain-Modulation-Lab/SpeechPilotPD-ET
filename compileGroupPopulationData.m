% compileGroupPopulationData.m
% ---------------------
% This script compiles population responses from the large population dataset, plotting the responses 
% for each electrode in the results structure along the way.

plotResponseHists = 0;
plotTrials = 1;
setDirectories;
align = {'Cue', 'Onset'};
%align = {'Onset'};
%freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2', 'alpha'};
locations = {'Precentral Gyrus', 'Postcentral Gyrus', 'Superior Temporal Gyrus'};
group='PD';
load([savedDataDir filesep group '_populationBehavior.mat']); %load population behavior
electrodeFile = [docDir filesep 'Ecog_Locations.xlsx'];
electrodeLocs = readElectrodeLocXLS(electrodeFile, group); 
rows = ceil(length(freq)/2);
PopResults = struct([]); medEventTimes = [];
for ll = 1:length(locations)
    for aa = 1:length(align)
        tracef = figure;
        %figure out the timebase we need for the population
        minT = 0; maxT = 0; nContactsTotal = 0; eventTimes = [NaN NaN NaN]; nTrialsTotal = 0;
        for ii=1:length(Results)
            trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).meanPSD,2));
            minT = min(minT, -Results(ii).(align{aa}).parameters{2});
            maxT = max(maxT, Results(ii).(align{aa}).parameters{4});
            contactLocs = Results(ii).(align{aa}).parameters{18};
            locMatch = find(strcmpi(contactLocs, locations{ll})); 
            nContactsTotal = nContactsTotal + length(locMatch);
            contacts = Results(ii).Cue.parameters{16};

            % calculate the trial timings 
            trialsUsed = Results(ii).Cue.parameters{10}; trialsUsed = trialsUsed(:); nTrials = length(trialsUsed);
            nTrialsTotal = nTrialsTotal + nTrials*length(locMatch);
            respTime = reshape(Results(ii).trials.SpOnset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed), [],1);
            respOffset = reshape(Results(ii).trials.SpOffset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed),[],1);
%             % Can inttegrate updated behavioral measures but won't change
%             % the alignment which is already done
%             respTime = reshape(sessionBehavior(ii).SpLatency(trialsUsed), [],1);
%             respOffset = respTime + reshape(sessionBehavior(ii).SpDuration(trialsUsed), [],1);
            if strcmp(align{aa}, 'Cue') %save event times for averaging/marking traces 
                eventTimes = cat(1, eventTimes, [zeros(nTrials,1) respTime respOffset]);
            else
                eventTimes = cat(1, eventTimes, [-respTime zeros(nTrials,1) respOffset-respTime]);
            end
        end
        medEventTimes = nanmedian(eventTimes);
        dt= mean(diff(trTime));
        minT = minT - dt*2; maxT = maxT+dt*2; %just to get an element of padding in case
        popTime = linspace(minT, maxT, (maxT-minT)/dt);
        popZeroInd = find(popTime >= 0,1);
        popZ = zeros(length(popTime), nContactsTotal, length(freq));
        popPvals = NaN*zeros(nContactsTotal, length(freq));
        meanz = struct([]); gammaMax = []; subj=[]; chan=[]; 
        trTime = linspace(-Results(1).(align{aa}).parameters{2}, Results(1).(align{aa}).parameters{4}, size(Results(1).(align{aa}).meanPSD,2));
        for ff = 1:length(freq) %frequency bands/plots
            zM = NaN*zeros(length(popTime), nContactsTotal);
            pvals = NaN*zeros(nContactsTotal,1);
            trial_z = NaN*zeros(length(popTime), nTrialsTotal); all_latencies = zeros(nTrialsTotal,1);
            zmi = 1; ti = 0;
            if strcmpi(align{aa}, 'Onset') && plotResponseHists % make an axis to plot the signal level histograms
                ncol = ceil(nContactsTotal/6);
                [hist_ah, ~] = subplot_pete(ceil(nContactsTotal/ncol), ncol, 'Z-score', 'Prob', [locations{ll} '  ' freq{ff}]);
            end
            for ii=1:length(Results) %subjects
                nTrials = Results(ii).(align{aa}).parameters{8};
                % selecting by contact location
                contactLocs = Results(ii).(align{aa}).parameters{18};
                locMatch = find(strcmpi(contactLocs, locations{ll})); 
                nchUsed = length(locMatch);
                nch = Results(ii).(align{aa}).parameters{12};
                trialsUsed = Results(ii).Cue.parameters{10}; trialsUsed = trialsUsed(:);
                trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).meanPSD,2));
                base = abs(Results(ii).((align{aa})).(freq{ff}).bs);
                signal = abs(Results(ii).((align{aa})).(freq{ff}).tr);

                subj_ti_start = ti;
                for jj=1:nchUsed  %electrode contacts
                    eNum = locMatch(jj);
                    signal_ch = signal(:,eNum:nch:end);
                    base_ch = base(:,eNum:nch:end);
                    z_amp = (signal_ch - nanmean(base_ch(:))) ./ nanstd(nanmean(base_ch,2));  %normalizes by the trial averaged mean/std
                    %z_amp = (signal_ch - repmat(nanmean(base_ch,1),size(signal_ch,1),1)) ... %normalizes by the within trial baseline mean/std
                    %          ./ repmat(nanstd(base_ch,0,1), size(signal_ch,1), 1);
                    
                    mean_z = nanmean(z_amp,2);
                    respTime = reshape(Results(ii).trials.SpOnset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed), [],1);
                    %compareResponseLatencies; %In for a sec, can remove once response latencies are verified
                    [~,latencyi] = sort(respTime);
                    meanz(ii,jj).amp = mean_z;  %save the signals to do some averaging
                    meanz(ii,jj).time = trTime;
                    zeroi = find(trTime >= 0,1);
                    len = length(mean_z);
                    if strcmpi(align{aa}, 'Onset') 
                        respTime = -respTime; 
                    end
                    if plotResponseHists
                        [pvals(zmi), h] = checkElectrodeSignificance(base_ch, signal_ch, zeroi, hist_ah(zmi));
                    else 
                        [pvals(zmi), h] = checkElectrodeSignificance(base_ch, signal_ch, zeroi);
                    end
                     
                    popInds = (popZeroInd - zeroi) + (1:len);
                    zM(popInds, zmi) = mean_z;
                    trial_z(popInds,ti+(1:length(trialsUsed))) = z_amp(:,latencyi);
                    all_latencies(ti+(1:length(trialsUsed))) = respTime(latencyi);
                    ti = ti+length(trialsUsed);
                    if isequal(freq{ff}, 'BroadbandGamma')
                        gammaMax(zmi) =  max(mean_z);
                        subj(zmi) = ii;
                        chan(zmi) = jj;
                    end

                    if pvals(zmi) < 0.05
                        figure(tracef);
                        traceah = subplot(rows, 2, ff);
                        plot(trTime, mean_z, 'k'); hold on;
                    end
                    medEventTimes(zmi,:) = nanmedian(eventTimes, 1);
                    meanEventTimes(zmi,:) = nanmean(eventTimes, 1);
                    zmi = zmi+1; %index for linear array of all contacts in dataset
                end
                
                % Plot the trial-wise responses for session
                if nchUsed > 0 && plotTrials
                    fh = figure;
                    sessioni = (subj_ti_start:(ti-1))+1;
                    minz = min(min(trial_z(popInds, sessioni)));
                    maxz = max(max(trial_z(popInds, sessioni)));
                    %caxis([minz maxz]); caxis([-10 ]);
                    pcolor(trTime, 1:size(trial_z(popInds, sessioni),2), trial_z(popInds, sessioni)'); 
                    shading flat; hold on;
                    colormap('parula'); colorbar;
                    xp = [all_latencies(sessioni), all_latencies(sessioni)]';
                    yp = repmat([0;1], 1, length(sessioni)) + (0:(length(sessioni)-1)); 
                    plot(xp, yp, 'r-', 'Linewidth', 2); 
                    title([Results(ii).Session 'Alignment: ' align{aa} ' ' freq{ff} ' ' locations{ll}]);
                    xlabel('Time (sec)');
                    ylabel('Trial Number (sorted by response latency)');
                    saveas(fh, sprintf('%s%sBandpassTrials%s%s-%s-%s-%s.bmp',figDir,filesep,filesep,Results(ii).Session,freq{ff},align{aa},locations{ll}),'bmp');
                    close(fh);
                end
            end
            plot(traceah, [trTime(1) trTime(end)], [3 3], '--r', 'LineWidth', 1);
            plot(traceah, [trTime(1) trTime(end)], [-3 -3], '--r', 'LineWidth', 1);
            sel = gammaMax >= 3;
            plot(traceah, popTime, nanmean(zM(:,sel), 2), 'r', 'LineWidth',2);
            eventPlotx = repmat(median(medEventTimes),2,1);
            plot(traceah, eventPlotx, [-10 -10 -10;10 10 10], 'k--'); 
            title(freq{ff});
            set(gca, 'Ylim', [-10 10]);
            if strcmp(align{aa},'Onset')
                set(gca,'Xlim', [-1.2 .8]);
            else
                set(gca, 'Xlim', [-.5 1.2]);
            end
            popPvals(:,ff) = pvals;
            popZ(:,:,ff) = zM;
        end
        axes(tracef, 'Position', [0, .9, .8, .1], 'Visible', 'off', 'Fontsize', 20);
        text(.5, .7, [locations{ll} '  Alignment: ' align{aa}]);

        eval([align{aa} '= struct(''popZ'', popZ, ''popPvals'', popPvals, ''subj'', subj, ''chan'', chan,''time'', popTime, ''gammaMax'', gammaMax, ''medEventTimes'', medEventTimes,''meanEventTimes'', meanEventTimes, ''eventTimes'', eventTimes);']);
        eval(['PopResults(1).loc(ll).' align{aa} '=' align{aa}]);
    end
end
PopResults.bands = freq;
PopResults.locations = locations;
save([group '_populationAvgs_Loc4.mat'], 'PopResults', '-v7.3'); 
%% 
% Assemble averages that are aligned on the proper timing
% dt = mean(diff(trTime));
% maxZeroInd = ceil(-minT/dt);
% freqMeans = zeros(maxlen, length(freq));
% for ff = 1:length(freq) %frequency bands/plots
%     zM = NaN*zeros(maxlen, nContactsTotal);
%     mi = 1;
%     for ii=1:length(Results) %subjects
%         for jj=1:Results(ii).(align).parameters{12}
%             zeroi=find(meanz(ii,jj).time > 0, 1,'first');
%             vl = length(meanz(ii,jj).amp);
%             offset = maxZeroInd - zeroi;
%             zM((1:vl)+maxZeroInd-offset-1,mi)= meanz(ii,jj).amp;
%             mi=mi+1;
%         end
%     end
%     freqMeans(:,ff) = nanmean(zM,2);
% end
% 
%      