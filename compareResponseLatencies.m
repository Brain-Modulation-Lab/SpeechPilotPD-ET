%compareResponseLatencies
allRespTime = NaN*zeros(60,1);
allRespTime(trialsUsed) = respTime;
diff_latencies = find(abs(sessionBehavior(ii).SpLatency - allRespTime') > 1e-4);
if isempty(diff_latencies)
    disp(['No latency differences in session ' num2str(ii)]);
else
    disp(['Latency difference in session ' num2str(ii)]);
end