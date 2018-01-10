% what vowel IPA codes do you want?
vowels = {'i', '\textscripta', 'u'};

% events per trial for this task
EventsPerTrial = 4;

% initialize output variable
VowelAudio = {[] [] []};
VowelTrials = {[] [] []};

for trial = 1:length(CodingMatrix)
    
    % determine
    codes = strsplit(CodingMatrix{1,trial}, '/');
    
    for v = 1:length(vowels)
        idx = find(cellfun(@(x) strcmp(vowels(v), x), codes));
        if ~isempty(idx) && ~isempty(CodingMatrix{9,trial}) && ~isempty(CodingMatrix{10,trial})
            VowelAudio{v}{end+1} = ...
                Audio(round(Afs*(EventTimes(SkipEvents+EventsPerTrial*trial)+CodingMatrix{9,trial})): ...
                        round(Afs*(EventTimes(SkipEvents+EventsPerTrial*trial)+CodingMatrix{10,trial})));
            VowelTrials{v}{end+1} = trial;
        end
    end
    
end

% go to output folder and write files
session = '3';

mkdir('VowelFiles');
cd VowelFiles

mkdir(['Session',session])
cd(['Session',session]);
for v = 1:length(vowels)
    
    mkdir(strrep(vowels{v}, '\', ''))
    for i=1:length(VowelAudio{v})
        temp = VowelAudio{v}{i};
        audiowrite([strrep(vowels{v}, '\', ''),'/','trial',num2str(VowelTrials{v}{i}),'.wav'],temp/(max(temp)-min(temp)),Afs);
    end
end

player = audioplayer(Afs);
