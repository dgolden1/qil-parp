function Y = fftfilt2(h, X, shape)
% Y = fftfilt2(h, X, shape)
% Two-dimensional fftfilt-style filtering using fast convolution and
% overlap-add
% 
% Uses "ffw" code by Luigi Rosa (http://www.advancedsourcecode.com/ffw.asp)
% 
% shape can be one of:
%     'same'  - (default) returns the central part of the 
%               correlation that is the same size as X.
%     'valid' - returns only those parts of the correlation
%               that are computed without the zero-padded
%               edges, size(Y) < size(X).
%     'full'  - returns the full 2-D correlation, 
%               size(Y) > size(X).

% By Daniel Golden (dgolden1 at stanford dot edu) June 2009
% $Id: fftfilt2.m 13 2012-08-10 19:30:42Z dgolden $

addpath(fullfile(danmatlabroot, 'ffw'));

persistent FFTiv FFTrv IFFTiv old_props old_opt
if isempty(FFTiv)
	load fftexecutiontimes;
end

% detbestlength2 takes a long time to run; try to use old options if
% they're still valid
sizeX = size(X);
sizeh = size(h);
isrealX = isreal(X);
isrealh = isreal(h);
props = [sizeX, sizeh, isrealX, isrealh];
if ~isempty(old_props) && all(old_props == props)
	opt = old_opt;
else
	opt = detbestlength2(FFTrv, FFTiv, IFFTiv, sizeX, sizeh, isrealX, isrealh);
	old_opt = opt;
	old_props = props;
end

Y = fftolamopt2(X, h, opt, shape); % Note that the order of h and X is reversed
