function [plhg]=PLHighGamma(signal,fs)


    baseline=signal(round(10*fs):round(40*fs));
    baseline=abs(hilbert(eegfilt(baseline',fs,80,200)'));
    ph1=angle(hilbert(eegfilt(signal(40*fs:end)',fs,4,30)'));
    filtered2=hilbert(eegfilt(signal(40*fs:end)',fs,80,200)');
    ph2=angle(filtered2);
    amp2=(abs(filtered2)-mean(baseline))./std(baseline);
    plhg=abs(smooth(amp2.*exp(1i.*(ph1-ph2)),fs));
    
    

end