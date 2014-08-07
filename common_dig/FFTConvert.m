function [f H_f freq FFT_f] = fftconvert(Data, fs);

% y = fftconvert(Raw,fs)
% by Morris Cohen
% takes Raw, performs fft, converts to normal scale

n = length(Data);
if mod(n,1) == 0
    Data = [Data; 0];
    n = length(Data);
end

RawFFT = fft(Data);
%RawFFT(1) = 0;

f = (-fs/2):(fs/n):(fs/2-1/n);
H_f = [RawFFT((n/2-.5):-1:2); RawFFT(1); RawFFT(n:-1:(n/2+.5))];

freq = 0:(fs/n):(fs/2+1/n);
FFT_f = [RawFFT(1); RawFFT(n:-1:(n/2+1.5)) + RawFFT(2:(n/2+.5))];

%subplot(2,1,1);plot(f,H_f);
%subplot(2,1,2);plot(freq,FFT_f);
