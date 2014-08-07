function odata = decimate_filter_only(idata, r)
% odata = decimate_filter_only(idata, r)
% Apply the same filter that decimate applies to the data as an
% antialiasing filter, but don't downsample
% 
% Code copied from decimate.m

% By Daniel Golden (dgolden1 at stanford dot edu) April 2011
% $Id: decimate_filter_only.m 13 2012-08-10 19:30:42Z dgolden $

nfilt = 8;
rip = 0.05; % passband ripple in dB

[b,a] = cheby1(nfilt, rip, .8/r);
while all(b==0) || (abs(filtmag_db(b,a,.8/r)+rip)>1e-6)
    nfilt = nfilt - 1;
    if nfilt == 0
        break
    end
    [b,a] = cheby1(nfilt, rip, .8/r);
end
if nfilt == 0
    error(generatemsgid('InvalidRange'),'Bad Chebyshev design, likely R is too big; try mult. decimation (R=R1*R2).')
end

odata = filtfilt(b,a,idata);

function H = filtmag_db(b,a,f)
%FILTMAG_DB Find filter's magnitude response in decibels at given frequency.

nb = length(b);
na = length(a);
top = exp(-1i*(0:nb-1)*pi*f)*b(:);
bot = exp(-1i*(0:na-1)*pi*f)*a(:);

H = 20*log10(abs(top/bot));
