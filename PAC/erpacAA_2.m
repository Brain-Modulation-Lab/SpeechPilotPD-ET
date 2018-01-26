function [pac1,pac2]=erpacAA_2(ph,amp)
ch=size(ph,3);

phdif=zeros(size(ph,1),size(ph,2),(ch^2-ch)/2);
k1=ch-1;k2=0;
r=[];c=[];
for i=1:ch
phdif(:,:,(1:k1)+((k2)))=bsxfun(@minus,ph(:,:,i),(ph(:,:,i+1:ch)));
r=[r; repmat(i,ch-i,1)];
c=[c; (i+1:ch)'];
k2=k1+k2;,
k1=k1-1;
end
parfor_progress(length(r));
pac1=zeros(size(phdif,1),size(r,1));pac2=pac1;
tic
for pr=1:size(r,1)
    for n=1:size(ph,1)
[pac1(n,pr) pv1(n,pr)] = circ_corrcl(squeeze(phdif(n,:,pr)),squeeze(amp(r(pr),n,:)));
    end
parfor_progress;
end
toc
parfor_progress(length(r));
tic
for pr=1:size(r,1)
    for n=1:size(ph,1)
[pac2(n,pr), pv2(n,pr)] = circ_corrcl(squeeze(phdif(n,:,pr)),squeeze(amp(c(pr),n,:)));
    end
parfor_progress;
end
toc
% do add later surrogates
%     surrr = zeros([surrogate_runs length(pac_value)]); % initialize
%     for s = 1:surrogate_runs
%         disp(['surrogate run: ' num2str(s)]);
%         a = ampdata(randperm(length(events)), :);
%         for t = 1:size(a, 2)
%             surrr(s, t) = circ_corrcl(phasedata(:, t), a(:, t));
%         end
%         clear t a
%     end
%     clear s surr p
% 
%     % z-score
%     pac_z = zeros([1 length(pac_value)]); % initialize
%     for t = 1:length(pac_value)
%         pac_z(t) = (pac_value(t) - mean(surrr(:, t))) ./ std(surrr(:, t));
%     end
%     clear t
% 
%     pac_sig = z2p(pac_z); % p-value from z-score
% I=find(~cellfun(@isempty,cellfun(@(x) find(x>100), tmp, 'UniformOutput', false)));
% Epairs=[r(I) c(I) I'];

end
