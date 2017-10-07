minT = 0; maxT = 0;
for ii=1:length(Results)
    trTime = linspace(-Results(ii).(align).parameters{2}, Results(ii).(align).parameters{4}, size(Results(ii).(align).zsc,2));    
    minT = min(minT, -Results(ii).(align).parameters{2});
    maxT = max(maxT, Results(ii).(align).parameters{4});
end
dt= mean(diff(trTime));
popTime = linspace(minT, maxT, (maxT-minT)/dt);
