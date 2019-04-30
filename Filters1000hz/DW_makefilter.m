% Filter design;
DW_machine;
deltaFilt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/deltaFilt.mat'],'deltaFilt');

thetaFilt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/thetaFilt.mat'],'thetaFilt');

alphaFilt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/alphaFilt.mat'],'alphaFilt');

beta1Filt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/beta1Filt.mat'],'beta1Filt');

beta2Filt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/beta2Filt.mat'],'beta2Filt');

gammaFilt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/gammaFilt.mat'],'gammaFilt');

hgammaFilt = designfilt;
save([dropbox,'Functions/Dengyu/Filter/hgammaFilt.mat'],'hgammaFilt');


save([dropbox,'Functions/Dengyu/Filter/bpFilt.mat'],'deltaFilt','thetaFilt','alphaFilt','beta1Filt','beta2Filt','gammaFilt','hgammaFilt');