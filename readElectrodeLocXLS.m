function electrodeLocations = readElectrodeLocXLS(filepath,sheet, varargin)
% function electrodeLocations = readElectrodeLocXLS(filepath)
%
% Reads in an excel spreadsheet format that gives anatomical location labels for all of the 
% ECoG electrode locations based on the localization.
if ~isempty(varargin)
    deleteEmptyLoc = varargin{1};
else
   deleteEmptyLoc = 0;
end
[~,~,raw] = xlsread(filepath,sheet); %returns cell array of 

entryRows = find(strncmpi('DBS',raw(:,1), 3)); 
for ii=1:length(entryRows)
    er = entryRows(ii);
    nch = raw{entryRows(ii)+2,1};
    loc.subject = raw{er,1};
    loc.side = raw{er+1,1};
    loc.nchannel = raw{er+2,1};
    locations={}; nums = [];
    switch nch
        case 6
            locations = raw(er-1+(1:6),3); %Anatomical locations
            nums = [raw{er-1+(1:6),2}]; %Channel numbers (important to denote if multiple strips)
        case 28
            for jj=1:2 %rows of electrodes in strip
                inds = (jj-1)*14+(1:14);
                locations(inds) = raw(er-1+(1:14),(2*jj)+1);
                nums(inds) = [raw{er-1+(1:14),2*jj}];
            end
        case 32
            for jj=1:2 %rows of electrodes in strip
                inds = (jj-1)*16+(1:16);
                locations(inds) = raw(er-1+(1:16),(2*jj)+1);
                nums(inds) = [raw{er-1+(1:16),2*jj}];
            end    
        case 36
            for jj=1:2 %rows of electrodes in strip
                inds = (jj-1)*18+(1:18);
                locations(inds) = raw(er-1+(1:18),(2*jj)+1);
                nums(inds) = [raw{er-1+(1:18),2*jj}];
            end        
        case 54
            for jj=1:3 %rows of electrodes in strip
                inds = (jj-1)*18+(1:18);
                locations(inds) = raw(er-1+(1:18),(2*jj)+1);
                nums(inds) = [raw{er-1+(1:18),2*jj}];
            end
    end
    if deleteEmptyLoc
        presenti = find(~strcmp(locations, 'No electrode'));
        locations = locations(presenti);
        nums = nums(presenti);
        loc.nchannel = length(nums);
    end
    loc.locations  = locations;
    loc.channels = nums;
    electrodeLocations(ii) = loc;
end