function respT = writeSummaryResultsFile(sd, fn)
% function writeSummaryResultsFile(sd, fn)
%
% Inputs: sd = summaryData, fn = filename
resp = struct([]);
ii = 1;
for ff=1:length(sd.freq_labels)
  nsites = length(sd.loc_labels);  
  for ll=1:nsites 
        for ee=1:size(sd.PD.freq(ff).loc(ll).perSessionZ,2)
            resp(ii).Group = 'PD';
            resp(ii).Frequency = sd.freq_labels{ff};
            resp(ii).Location = sd.loc_labels{ll};
            resp(ii).ElectrodeLabel = sd.PD.freq(ff).loc(ll).electrodeLabel{ee};
            resp(ii).PeakZ = sd.PD.freq(ff).loc(ll).peakval(ee);
            resp(ii).PeakTime = sd.PD.freq(ff).loc(ll).peakt(ee);
            resp(ii).FirstSigResponseTime = sd.PD.freq(ff).loc(ll).firstSigT(ee);
            ii = ii+1;
        end
        for ee=1:size(sd.ET.freq(ff).loc(ll).perSessionZ,2)
            resp(ii).Group = 'ET';
            resp(ii).Frequency = sd.freq_labels{ff};
            resp(ii).Location = sd.loc_labels{ll};
            resp(ii).ElectrodeLabel = sd.ET.freq(ff).loc(ll).electrodeLabel{ee};
            resp(ii).PeakZ = sd.ET.freq(ff).loc(ll).peakval(ee);
            resp(ii).PeakTime = sd.ET.freq(ff).loc(ll).peakt(ee);
            resp(ii).FirstSigResponseTime = sd.ET.freq(ff).loc(ll).firstSigT(ee);
            ii = ii+1;
        end
  end
  
end

respT = struct2table(resp);
writetable(respT, fn);



