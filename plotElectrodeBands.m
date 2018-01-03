% plotElectrodeBands.m
% ---------------------
% This script compiles population responses from the large population dataset, plotting the responses 
% for each electrode in the results structure along the way.

align = {'Cue', 'Onset'};
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
rows = ceil(length(freq)/2);
PopResults = struct([]); chEventTimes = [];
for aa = 1:length(align)
    figure;
    %lets figure out the timebase we need for the population
    minT = 0; maxT = 0; nContactsTotal = 0; meanEventTimes = [];
    for ii=1:length(Results)
        trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).zsc,2));
        minT = min(minT, -Results(ii).(align{aa}).parameters{2});
        maxT = max(maxT, Results(ii).(align{aa}).parameters{4});
        nContactsTotal = nContactsTotal + Results(ii).(align{aa}).parameters{12};
        
        % calculate the trial timings 
        trialsUsed = Results(ii).Cue.parameters{10}; trialsUsed = trialsUsed(:);
        respTime = reshape(Results(ii).trials.SpOnset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed), [],1);
        respOffset = reshape(Results(ii).trials.SpOffset(trialsUsed),[],1) - reshape(Results(ii).trials.CommandStim(trialsUsed),[],1);
        if strcmp(align{aa}, 'Cue') %save event times for averaging/marking traces 
            meanEventTimes(ii,:) = [0 mean(respTime) mean(respOffset)];
        else
            meanEventTimes(ii,:) = [-mean(respTime) 0 mean(respOffset-respTime)];
        end
    end
    dt= mean(diff(trTime));
    minT = minT - dt; maxT = maxT+dt; %just to get an element of padding in case
    popTime = linspace(minT, maxT, (maxT-minT)/dt);
    popZeroInd = find(popTime >= 0,1);
    popZ = zeros(length(popTime), nContactsTotal, length(freq));
    
    meanz = struct([]); gammaMax = []; subj=[]; chan=[];
    trTime = linspace(-Results(1).(align{aa}).parameters{2}, Results(1).(align{aa}).parameters{4}, size(Results(1).(align{aa}).zsc,2));
    for ff = 1:length(freq) %frequency bands/plots
        zM = NaN*zeros(length(popTime), nContactsTotal);
        zmi = 1;
        for ii=1:length(Results) %subjects
            nTrials = Results(ii).(align{aa}).parameters{8};
            nch = Results(ii).(align{aa}).parameters{12};
            trTime = linspace(-Results(ii).(align{aa}).parameters{2}, Results(ii).(align{aa}).parameters{4}, size(Results(ii).(align{aa}).zsc,2));
            base = abs(Results(ii).((align{aa})).(freq{ff}).bs);
            signal = abs(Results(ii).((align{aa})).(freq{ff}).tr);
            
            for jj=1:nch  %electrode contacts
                signal_ch = signal(:,jj:nch:end);
                base_ch = base(:,jj:nch:end);
                z_amp = (signal_ch - mean(mean(base_ch,2))) / std(mean(base_ch,2));
                mean_z = mean(z_amp,2);
                
                meanz(ii,jj).amp = mean_z;  %save the signals to do some averaging
                meanz(ii,jj).time = trTime;
                zi = find(trTime >= 0,1);
                len = length(mean_z);
                popInds = (popZeroInd - zi) + (1:len);
                zM(popInds, zmi) = mean_z;
                if isequal(freq{ff}, 'BroadbandGamma')
                    gammaMax(zmi) =  max(mean_z);
                    subj(zmi) = ii;
                    chan(zmi) = jj;
                end
                
                if gammaMax(zmi) >= 5
                    subplot(rows, 2, ff);
                    plot(trTime, mean_z, 'k'); hold on;
                end
                chEventTimes(zmi,:) = meanEventTimes(ii,:);
                zmi = zmi+1;
            end
        end
        plot([trTime(1) trTime(end)], [3 3], '--r', 'LineWidth', 1);
        plot([trTime(1) trTime(end)], [-3 -3], '--r', 'LineWidth', 1);
        sel = gammaMax >= 3;
        plot(popTime, nanmean(zM(:,sel), 2), 'r', 'LineWidth',2);
        eventPlotx = repmat(mean(chEventTimes),2,1);
        plot(eventPlotx, [-10 -10 -10;10 10 10], 'k--'); 
        title(freq{ff});
        set(gca, 'Ylim', [-10 10]);
        if strcmp(align{aa},'Onset')
            set(gca,'Xlim', [-1.2 .8]);
        else
            set(gca, 'Xlim', [-.5 1.2]);
        end
        popZ(:,:,ff) = zM;
    end
    axes(gcf, 'Position', [0, .9, .8, .1], 'Visible', 'off', 'Fontsize', 20);
    text(.5, .7, ['Alignment: ' align{aa}]);
    eval([align{aa} '= struct(''popZ'', popZ, ''subj'', subj, ''chan'', chan,''time'', popTime, ''gammaMax'', gammaMax, ''chEventTimes'', chEventTimes);']);
    eval(['PopResults(1).' align{aa} '=' align{aa}]);
end
PopResults.bands = freq;
%save('ET_populationAvgs.mat', 'PopResults', '-v7.3'); 
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