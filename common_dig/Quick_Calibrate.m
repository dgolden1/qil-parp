function [FrequencyResponseNS FrequencyResponseEW CalibrationNumberNS CalibrationNumberEW NoiseResponseNS NoiseResponseEW CrossTalkResponseEWtoNS CrossTalkResponseNStoEW] = Calibrate;

%
%  --------------------------------
%  -----VLF Calibration Script-----
%  --------------------------------
%
%  Made by Morris Cohen, November 2004
%  Last updated November 2005
%
%  This script can be used to calibrate the response of the 2005 Stanford
%  VLF receiver, which was completed by Morris Cohen and Justin Tan in Fall
%  of 2005.
%
%  To use this program, you will need a matlab datafile which contains a
%  calibration tone, taken with a dummy loop attached to the front end of
%  the preamplifier.  See the documentation of the 2005 VLF receiver for
%  information on how to do this.  You will also need to know the antenna's
%  size and turn number.
%
%  This script can be used as follows
%
%  A variable, [responseNS responseEW] which will map out the frequency
%  response of the system, on both channels.  The units are in mV/pT,
%  meaning the number corresponds to the magnitude signal at the output (in
%  millivolts) that would be generated from a 1picotesla input to the
%  antenna. Each incremental row value is in frequency multiples of
%  250.244 Hz, beginning with zero.  You'll also have the inverse response,
%  which can be used to convert data to pT.
%
%  In addition, the script will graph the result, for both channels.
%

j = sqrt(-1);

antennaarea = input('Area of antenna (square meters) ');
antennaturns = input('Number of turns of wire ');
antennainductance = input('Inductance of antenna (mH, nominally 1) ');
antennaresistance = input('Resistance of antenna (Ohms, nominally 1) ');

[filename0, pathname, filterindex] = uigetfile('.mat', 'N/S Calibration Data');
cd(pathname)
[filename1, pathname, filterindex] = uigetfile('.mat', 'E/W Calibration Data');

interleaved = 0;
if strcmp(filename0, filename1) ==1
    interleaved = input ('Interleaved? (1 for yes) ');
end

caltonelocation = input('Location of caltone onset (seconds from start of file) ');
noisetonelocation = input('Location of noisetone (any second that is not a caltone) ');

fid0 = fopen (filename0, 'r');
fid1 = fopen (filename1, 'r');
if interleaved == 1
    caltone = matGetVariable (fid0, 'data', 200000, caltonelocation*200000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
    caltoneNS = caltone(1:2:end);
    caltoneEW = caltone(2:2:end);
    fclose(fid0);
else
    caltoneNS = matGetVariable (fid0, 'data', 100000, caltonelocation*100000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
    if strcmp(filename0, filename1) ==1
        fid1 = fopen (filename1, 'r');
    end
    caltoneEW = matGetVariable (fid1, 'data', 100000, caltonelocation*100000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
    fclose(fid0);
    fclose(fid1);
end

fid0 = fopen (filename0, 'r');
fid1 = fopen (filename1, 'r');
if interleaved == 1
    noisetone = matGetVariable (fid0, 'data', 200000, noisetonelocation*200000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
    noisetoneNS = noisetone(1:2:end);
    noisetoneEW = noisetone(2:2:end);
    fclose(fid0);
else
    noisetoneNS = matGetVariable (fid0, 'data', 100000, noisetonelocation*100000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
    if strcmp(filename0, filename1) ==1
        fid1 = fopen (filename1, 'r');
    end
    noisetoneEW = matGetVariable (fid1, 'data', 100000, noisetonelocation*100000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
    fclose(fid0);
    fclose(fid1);
end

existsCrossTalk = input('Cross talk data exists? (1 for yes) ');

if existsCrossTalk == 1
    [filename0, pathname1, filterindex] = uigetfile('.mat', 'E/W Cross Talk Onto N/S, N/S Channel');
    caltonelocation0 = input('Location of caltone onset (seconds from start of file, caltone should be on E/W channel only) ');
    cd(pathname1)
    [filename1, pathname2, filterindex] = uigetfile('.mat', 'E/S Cross Talk Onto E/W, E/W Channel');
    caltonelocation1 = input('Location of caltone onset (seconds from start of file, caltone should be on N/S channel only) ');

    fid0 = fopen (filename0, 'r');
    cd(pathname2)
    fid1 = fopen (filename1, 'r');
    if interleaved == 1
        crosstalktoneNS = matGetVariable (fid0, 'data', 200000, caltonelocation0*200000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
        fclose(fid0);
        if strcmp(filename0, filename1) ==1
            fid1 = fopen (filename1, 'r');
        end
        crosstalktoneEW = matGetVariable (fid1, 'data', 200000, caltonelocation1*200000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
        fclose(fid1);
        crosstalktoneEWtoNS = crosstalktoneNS(1:2:end);
        crosstalktoneNStoEW = crosstalktoneEW(2:2:end);
    else
        crosstalktoneEWtoNS = matGetVariable (fid0, 'data', 100000, caltonelocation0*100000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
        if strcmp(filename0, filename1) ==1
            fid1 = fopen (filename1, 'r');
        end
        crosstalktoneNStoEW = matGetVariable (fid1, 'data', 100000, caltonelocation1*100000+1)/(2^16)*10000;  % 2^16 for 16 bit sampling, 10000 in mV full scale sampling
        fclose(fid0);
        fclose(fid1);
    end
end

Rcal = 10000;  % calibration injection resistance
Ld = .001;  % dummy loop inductance
Rmatch = 1;
Vcal = .00283;  % 1mV-RMS = 2.83mVpp

conversion = antennainductance/(Rcal*antennaturns*antennaarea);  % mV per pT conversion factor
Bcal = Vcal*conversion;  % equivalent magnetic field to calibration tone, valid for f >> Ra/La


caltonepieceNS = [caltoneNS; zeros(299609,1)];  % zero pads
caltonepieceEW = [caltoneEW; zeros(299609,1)];  % zero pads
caltonefftNS = fft(caltonepieceNS);  % fft of caltone segment
caltonefftEW = fft(caltonepieceEW);  % fft of caltone segment

noisetonepieceNS = [noisetoneNS; zeros(299609,1)];  % zero pads
noisetonepieceEW = [noisetoneEW; zeros(299609,1)];  % zero pads
noisetonefftNS = fft(noisetonepieceNS);  % fft of noisetone segment
noisetonefftEW = fft(noisetonepieceEW);  % fft of noisetone segment

if existsCrossTalk == 1
    crosstalktonepieceNStoEW = [crosstalktoneNStoEW; zeros(299609,1)];
    crosstalktonepieceEWtoNS = [crosstalktoneNStoEW; zeros(299609,1)];
    crosstalktoneNStoEWfft = fft(crosstalktonepieceNStoEW);
    crosstalktoneEWtoNSfft = fft(crosstalktonepieceNStoEW);
end

responseNS = zeros(200,1);  % empty response
responseEW = zeros(200,1);  % empty response

noiseresponseNS = zeros(200,1);  % empty noise response
noiseresponseEW = zeros(200,1);  % empty noise response

if existsCrossTalk == 1
    crosstalkNStoEW = zeros(200,1);  % empty cross talk response
    crosstalkEWtoNS = zeros(200,1);  % empty cross talk response
end

responseRatio = ones(200,1);  % empty response ratio

for ii = 1:199
    correctionfactor = Rcal*(1+antennaresistance+i*2*pi*
    responseNS(ii+1) = max(abs(caltonefftNS((1+ii*1000-2):(1+ii*1000+2))))/100000*conversion;  % calculate gain response for each 250Hz point, in units of mV(output)/pT(input).  100000mV = full scale
    responseEW(ii+1) = max(abs(caltonefftEW((1+ii*1000-2):(1+ii*1000+2))))/100000*conversion;  % calculate gain response for each 250Hz point, in units of mV(output)/pT(input)
    responseRatio(ii+1) = responseNS(ii+1)/responseEW(ii+1);
    noiseresponseNS(ii+1) = sum(abs(noisetonefftNS((1+ii*1000-500):(1+ii*1000+500))))/100000*conversion/1000/sqrt(0.25);  % calculate gain response for each 250Hz point, in units of mV(output)/pT(input), bandwidth each fft point is 0.25Hz
    noiseresponseEW(ii+1) = sum(abs(noisetonefftEW((1+ii*1000-500):(1+ii*1000+500))))/100000*conversion/1000/sqrt(0.25);  % calculate gain response for each 250Hz point, in units of mV(output)/pT(input), bandwidth each fft point is 0.25Hz
    if existsCrossTalk == 1
        crosstalkEWtoNS(ii+1) = responseNS(ii+1)/max(responseNS(ii+1)/2^16,(max(abs(crosstalktoneEWtoNSfft((1+ii*1000-2):(1+ii*1000+2))))/100000*conversion-noiseresponseNS(ii+1)));
        crosstalkNStoEW(ii+1) = responseEW(ii+1)/max(responseEW(ii+1)/2^16,(max(abs(crosstalktoneNStoEWfft((1+ii*1000-2):(1+ii*1000+2))))/100000*conversion-noiseresponseEW(ii+1)));
    end
end

AtmosphereNoise = [
    .100 -15
    .200 -18
    .300 -22
    .400 -25
    .500 -27
    .600 -29
    .700 -28
    .800 -27
    .900 -30
    1.000 -31
    2.000 -35
    3.000 -40
    4.000 -42
    5.000 -40
    6.000 -37
    7.000 -35
    8.000 -32
    9.000 -30
    10.000 -28
    15.000 -28
    20.000 -31
    30.000 -34
    40.000 -38
    50.000 -42
    ];  % taken from figure 2 of "what and where is the natural noise floor"

FrequencyResponseNS = [transpose(0:0.250244:50) responseNS];
FrequencyResponseEW = [transpose(0:0.250244:50) responseEW];
CalibrationNumberNS = [transpose(0:0.250244:50) 1./(responseNS/1000*10*2^16)];
CalibrationNumberEW = [transpose(0:0.250244:50) 1./(responseEW/1000*10*2^16)];
NoiseResponseNS = [transpose(0:0.250244:50) noiseresponseNS];
NoiseResponseEW = [transpose(0:0.250244:50) noiseresponseEW];
if existsCrossTalk == 1
    CrossTalkResponseEWtoNS = [transpose(0:0.250244:50) crosstalkEWtoNS];
    CrossTalkResponseNStoEW = [transpose(0:0.250244:50) crosstalkNStoEW];
end

figure()
subplot(2,1,1)
plot(0:0.250244:50,responseNS);
title ('NS Channel Calibration Response','FontSize',16)
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('Output/Input Gain (mV/pT)','FontSize',16)
set(gca,'FontSize',16)
subplot(2,1,2)
plot(0:0.250244:50,responseEW);
title ('EW Channel Calibration Response','FontSize',16)
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('Output/Input Gain (mV/pT)','FontSize',16)
set(gca,'FontSize',16)

figure()
subplot(2,1,1)
plot(0:0.250244:50,1./(responseNS/1000*10*2^16));
title ('NS Channel Calibration Number','FontSize',16)
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('Calibration Number (pT/increment)','FontSize',16)
set(gca,'FontSize',16)
subplot(2,1,2)
plot(0:0.250244:50,1./(responseEW/1000*10*2^16));
title ('EW Channel Calibration Number','FontSize',16)
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('Calibration Number (pT/increment)','FontSize',16)
set(gca,'FontSize',16)

figure()
plot(0:0.250244:50,responseRatio);
title ('Channel Calibration Response Ratio','FontSize',16)
axis ([0 50 0 2])
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('NS/EW Response Ratio','FontSize',16)
set(gca,'FontSize',16)

figure()
subplot(2,1,1)
plot(0:0.250244:50,20*log10(noiseresponseNS), AtmosphereNoise(:,1), AtmosphereNoise(:,2));
title ('NS Channel Noise Response','FontSize',16)
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('Noise Level dB-pT/sqrt(Hz)','FontSize',16)
set(gca,'FontSize',16)
subplot(2,1,2)
hold on
plot(0:0.250244:50,20*log10(noiseresponseEW), AtmosphereNoise(:,1), AtmosphereNoise(:,2));
title ('EW Channel Noise Response','FontSize',16)
xlabel ('Frequency (kHz)','FontSize',16)
ylabel ('Noise Level dB-pT/sqrt(Hz)','FontSize',16)
set(gca,'FontSize',16)

if existsCrossTalk == 1
    figure()
    subplot(2,1,1)
    plot(0:0.250244:50,-20*log10(crosstalkEWtoNS));
    title ('Cross talk E/W Channel onto N/S Channel','FontSize',16)
    xlabel ('Frequency (kHz)','FontSize',16)
    ylabel ('Ratio (dB)','FontSize',16)
    set(gca,'FontSize',16)
    subplot(2,1,2)
    plot(0:0.250244:50,-20*log10(crosstalkNStoEW));
    title ('Cross talk N/S Channel onto E/W Channel','FontSize',16)
    xlabel ('Frequency (kHz)','FontSize',16)
    ylabel ('Ratio (dB)','FontSize',16)
    set(gca,'FontSize',16)
end
