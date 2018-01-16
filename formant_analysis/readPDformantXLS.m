function formant_freqs = readPDformantXLS()

setDirectories;
filepath = [codeDir filesep 'formant_analysis' filesep 'PD_formant_freqs.xlsx'];
[~,~,raw] = xlsread(filepath,'FCR'); %returns cell array of sheet

subjrow = find(strncmp('DBS', raw(:,2),3));

entryRows = [subjrow(1:end-1)+1 subjrow(2:end)-1];
entryRows(end+1, :) = [subjrow(end)+1 size(raw,1)];
ii = 1;
for s = 1:length(subjrow)
   sessions = cell2mat(raw(entryRows(s,1):entryRows(s,2), 3));
   iu_ratio = cell2mat(raw(entryRows(s,1):entryRows(s,2), 4)); 
   for j=1:length(sessions)
       formant_freqs(ii).subject = raw{subjrow(s),2};
       formant_freqs(ii).session = sessions(j);
       formant_freqs(ii).iu_ratio = iu_ratio(j);
       ii = ii+1;
   end
end