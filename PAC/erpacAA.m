function [pac1]=erpacAA(ph,amp)
t=size(ph,3);

    pac1=zeros(size(ph,1),size(amp,1),size(ph,2));
    
 for pr=1:size(ph,1)
    
    for ar=1:size(amp,1)
[pac1(pr,ar,:) ] = circ_corrcl_AA(squeeze(ph(pr,:,randperm(t)))',squeeze(amp(ar,:,randperm(t)))');
    end
    
    
end
end