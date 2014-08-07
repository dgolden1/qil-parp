function [varName,varType,varRows,varCols,varImag,varSize]=matReadHeaderKludge(fid,offset)

% function [varName,varType,varRows,varCols,varImag,varSize]=matReadHeaderKludge(fid,offset)
%
% Reads a header from a Version 4 .mat file at the current (or specified)
%  file position and returns information about the next variable data.
%  This function should probably not be used directly, but is called
%  by matGetVariableInfo  and matGetVariableData.
% varSize is the length in bytes of the datatype varType.
%
% The .mat file should be opened and closed elsewhere.
%
% BUGS:-  Can only deal with 5 types of MATLAB variable, and only those
%           with 0, 1, or 2 dimensions.
%      -  Does matlab always save with the same machineformat? Machine format not yet fixed.
%      -  i.e., ONLY TESTED ON P.C.'S SO FAR!
%      -  DOES NOT DEAL WITH COMPLEX NUMBERS YET
%
% by cPbL@alum.mit.edu and Robert M Barrington Leigh, 2000 August 23
% Modified by Daniel Golden (dgolden1 at stanford dot edu) September 2007

% $Id: matReadHeaderKludge.m 2 2012-08-02 23:59:40Z dgolden $


varName=-1;varType=-1;varRows=-1;varCols=-1;varImag=-1;varSize=-1; % THIS LINE AVOIDS A MATLAB "UNASSIGNED ARGUMENTS" WARNING

if nargin>1
	fseek(fid,offset,'bof')
end%if

%keyboard
varTypeCode=fread(fid,1,'int32');
err = ferror(fid);
if feof(fid),
   return;
else
	error(err);
end%if

switch (varTypeCode)
case 0% double
   varType='double';
   varSize=8;
case 10% float
   varType='float32';
   varSize=4;
case 20% integer
   varType='int';
   varSize=4;
case 30% short
   varType='int16';
   varSize=2;
case 40% ushort
   varType='uint16';
   varSize=2;
case 50% char
   varType='uchar'; % OR IS IT SCHAR???????????
   varSize=1;
otherwise
   error(['PROBLEM! UNKNOWN DATA TYPE: %d\n' ...
   'Likely this .mat file is not in Version 4 .MAT format.\n' ...
   'VLF .mat data files written from acquisition programs are\n' ...
   'generally in Version 4 format.'], varTypeCode);
%    warning(sprintf('PROBLEM! UNKNOWN DATA TYPE: %d',varTypeCode));
%    disp('Likely this .mat file is not in Version 4 .MAT format.');
%    disp('  VLF .mat data files written from acquisition programs are');
%    disp('  generally in Version 4 format.');
%    disp('  Returning NaN from matReadHeaderKludge.');
%    varName=NaN;
%    return;
end%switch

varRows=fread(fid,1,'int32');
varCols=fread(fid,1,'int32');
varImag=fread(fid,1,'int32');
varNameLength=fread(fid,1,'int32');
varNameWithSpace=char(fread(fid,varNameLength,'char'))';
% AS FAR AS I CAN TELL (DON'T KNOW WHY), MATLAB APPENDS A SPACE TO 
%  EACH VARIABLE NAME. THE LENGTH, ABOVE, INCLUDES THE SPACE.
varName=varNameWithSpace(1:(end-1));


% Data from Summer 2004 has a bug where the 'data' variable is reported as
% being float32 data, but is in fact int16 data. We'll throw this kludge in
% and hope it doesn't cause problems with any other files where a 'data'
% variable actually IS float32. Optimally, we should fix the original data
% files. --DIG
if strcmp(varName, 'data') && strcmp(varType, 'float32')
   varType='int16';
   varSize=2;
end

varOffset=ftell(fid);

% ONE SANITY CHECK:
if varRows<0 || varCols<0
   error(' Matlab file is corrupt: it claims negative dimension sizes.');
end%if
