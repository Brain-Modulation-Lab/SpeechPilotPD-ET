% plot the responses for each electrode in the results trial

align = 'Onset';
freq={'BroadbandGamma','Gamma','Hgamma','beta1','beta2','delta','theta','alpha'};
figure;
rows = ceil(length(freq)/2);

%lets figure out the timebase we need for the population
minT = 0; maxT = 0; nContactsTotal = 0;
for ii=1:length(Results)
    trTime = linspace(-Results(ii).(align).parameters{2}, Results(ii).(align).parameters{4}, size(Results(ii).(align).zsc,2));    
    minT = min(minT, -Results(ii).(align).parameters{2});
    maxT = max(maxT, Results(ii).(align).parameters{4});
    nContactsTotal = nContactsTotal + Results(ii).(align).parameters{12};
end
dt= mean(diff(trTime));
popTime = linspace(minT, maxT, (maxT-minT)/dt);
popZeroInd = find(popTime >= 0,1);
popAvgZ = zeros(length(popTime), length(freq));

meanz = struct([]);
trTime = linspace(-Results(1).(align).parameters{2}, Results(1).(align).parameters{4}, size(Results(1).(align).zsc,2));
for ff = 1:length(freq) %frequency bands/plots
    zM = NaN*zeros(length(popTime), nContactsTotal);
    zmi = 1;
    for ii=1:length(Results) %subjects
        nTrials = Results(ii).(align).parameters{8};
        nch = Results(ii).(align).parameters{12};
        trTime = linspace(-Results(ii).(align).parameters{2}, Results(ii).(align).parameters{4}, size(Results(ii).(align).zsc,2));
        base = abs(Results(ii).((align)).(freq{ff}).bs);
        signal = abs(Results(ii).((align)).(freq{ff}).tr);
        
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
            zmi = zmi+1;
            if isequal(freq{ff}, 'BroadbandGamma')
                gamma_max(ii, jj) =  max(mean_z);
            end
            
            if gamma_max(ii,jj) >= 5
                
                subplot(rows, 2, ff);
                plot(trTime, mean_z, 'k'); hold on;
            end
        end
    end
    plot([trTime(1) trTime(end)], [3 3], '--r', 'LineWidth', 1);
    plot([trTime(1) trTime(end)], [-3 -3], '--r', 'LineWidth', 1);
    plot(popTime, mean(zM, 2), 'r', 'LineWidth',2);
    title(freq{ff});
    set(gca, 'Ylim', [-10 10]);
end

%% 
% Assemble averages that are aligned on the proper timing
dt = mean(diff(trTime));
maxZeroInd = ceil(-minT/dt);
freqMeans = zeros(maxlen, length(freq));
for ff = 1:length(freq) %frequency bands/plots
    zM = NaN*zeros(maxlen, nContactsTotal);
    mi = 1;
    for ii=1:length(Results) %subjects
        for jj=1:Results(ii).(align).parameters{12}
            zeroi=find(meanz(ii,jj).time > 0, 1,'first');
            vl = length(meanz(ii,jj).amp);
            offset = maxZeroInd - zeroi;
            zM((1:vl)+maxZeroInd-offset-1,mi)= meanz(ii,jj).amp;
            mi=mi+1;
        end
    end
    freqMeans(:,ff) = nanmean(zM,2);
end

     