function electrodeInfo = loadFinalEcogLocations(FN, group)
%function electrodeInfo = loadFinalEcogLocations(FN, group)

setDirectories; %platform specific locations
subjectLists;
if ~iscell(group)
    group = {group};
end
%group = {'PD','ET'};
%electrodeInfoFN = [savedDataDir filesep 'population' filesep 'ecog_coords_final.xlsx'];
opts = detectImportOptions(FN);
kk=1;
for gg=1:length(group)
    opts.Sheet = group{gg};
    T = readtable(FN, opts);
    subjects = eval([group{gg} '_subjects']);
    for ii=1:length(subjects)
        matchi = find(strcmp(T.Subject(:), subjects{ii}));
        T2 = T(matchi,:);
        sides = T2{:, 'Side'};
        sl = unique(sides);
        for jj=1:length(sl)
            matchs = strncmpi(sides, sl{jj}, 1);
            e.subject = subjects{ii};
            e.side = sl{jj};
            e.MNI_coord = T2{matchs, {'x_mni', 'y_mni', 'z_mni'}};
            e.native_coord = T2{matchs, {'x_indiv', 'y_indiv', 'z_indiv'}};
            e.location = T2{matchs,'location_native'};
            e.label = T2{matchs, 'ft_label'};
            %e.contact_idx = cellfun(@(x) str2double(x), T2{matchs,'contact_idx'});
            e.contact_idx =  T2{matchs,'contact_idx'};
            electrodeInfo(kk) = e;
            kk = kk+1;
        end
    end
end
