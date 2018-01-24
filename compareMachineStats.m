%compare local and remote stats

l = load('comparison_stats_local.mat');
r = load('comparison_stats_remote.mat');
max_diff = 0;
figure;
for ii = 1:length(l.p_saved);
    pdiff = r.p_saved{ii} - l.p_saved{ii};
    subplot(3,1,1);
    plot(pdiff); 
    max_diff = max(max(abs(pdiff)), max_diff);
    subplot(3,1,2);
    plot(r.p_saved{ii}-.05, 'b'); hold on;
    plot([0 4000], [0 0], 'r'); hold off;
    %hdiff = r.h_saved{ii} - l.h_saved{ii};
    %plot(hdiff); hold on;
    subplot(3,1,3)
    plot(r.h_saved{ii}, 'r', 'Linewidth', 1); hold on;
    plot(l.h_saved{ii}, 'k'); hold off;
end
ylim([-1.1 1.1]);
disp(['Maximum p_value difference is ' num2str(max_diff,4)]);