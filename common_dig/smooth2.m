function matrixOut = smooth2(matrixIn, Nr, Nc)

% SMOOTH2.M: Smooths matrix data.
% 
%			MATRIXOUT=SMOOTH2(MATRIXIN,Nr,Nc) smooths the data in MATRIXIN 
%           using a running mean over N successive points.  At the ends of
%           the series skewed or one-sided means are used.  
%
%           Inputs: matrixIn - original matrix
%                   Nr - number of points used to smooth each row
%                   Nc - number of points to smooth each column
%           Outputs:matrixOut - smoothed version of original matrix
%
%           Remark: By default, if Nc is omitted, Nc = Nr.

%           Written by Kelly Hilands, October 2004
%           Applied Research Laboratory
%           Penn State University
%
%           Developed from code written by Olof Liungman, 1997
%			Dept. of Oceanography, Earth Sciences Centre
%			G�teborg University, Sweden
%			E-mail: olof.liungman@oce.gu.se
% 
%			Rewritten using the 1-D smooth() function
%			by Daniel Golden (dgolden1 at stanford dot edu) Jan 2009


%Initial error statements and definitions
if nargin < 2, error('Not enough input arguments!'), end

if nargin < 2 
    Nr = 5;
end
if nargin < 3
	Nc = Nr;
end

matrixOut = matrixIn;


% Smooth each row
if Nr > 0
	for kk = 1:size(matrixIn, 1)
		matrixOut(kk, :) = smooth(matrixIn(kk, :), Nc);
	end
end

% Smooth each column
if Nc > 0
	for kk = 1:size(matrixIn, 2)
		matrixOut(:, kk) = smooth(matrixOut(:, kk), Nr);
	end
end
