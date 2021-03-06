
setDirectories;
filepath = [codeDir filesep 'formant_analysis' filesep 'ET_formant_freqs.xlsx'];
[~,~,raw] = xlsread(filepath,'Sheet1'); %returns cell array of sheet
vowels = {'i', 'u'};

titleRows = find(strncmpi('DBS',raw(:,1), 3));
subjects = raw(titleRows,1);
sessions = raw(titleRows,2);

entryRows = [titleRows(1:end-1)+1 titleRows(2:end)-3];
entryRows(end+1, :) = [titleRows(end)+1 size(raw,1)];

for ii=1:length(sessions)
    for v=1:length(vowels)
        trials = raw(entryRows(ii,1):entryRows(ii,2),((v-1)*4) + 3);
        trialNums = cellfun(@(x) extractTrialNum(x), trials);
        nz = find(trialNums > 0 & trialNums <= 60); 
        [~,sorti] = sort(trialNums(nz)); %reorder but also use to select via nz
        
        F1 = cell2mat(raw(entryRows(ii,1):entryRows(ii,2),((v-1)*4) + 4));
        F2 = cell2mat(raw(entryRows(ii,1):entryRows(ii,2),((v-1)*4) + 5));
        formantfreqs(ii).(vowels{v}).trials = trialNums(sorti);
        formantfreqs(ii).(vowels{v}).F1 = F1(sorti);
        formantfreqs(ii).(vowels{v}).F2 = F2(sorti);     
    end
    formantfreqs(ii).iu_ratio = mean(formantfreqs(ii).i.F2)/mean(formantfreqs(ii).u.F2);
    formantfreqs(ii).session = sessions{ii};
    formantfreqs(ii).subject = subjects{ii};
end
