function dist = angledist(angle1, angle2, str_rad_or_deg, b_signed)
% dist = angledist(angle1, angle2, str_rad_or_deg, b_signed)
% Find distance in between two angles
% Angles can be unwrapped; they will be modded to 360 degrees for the
% computation
% 
% INPUTS
% str_rad_or_deg: either 'rad' or 'deg'. It is 'deg' by default.
% b_signed: true to use a signed angle distance (i.e., if angle2 is further
%  around the unit circle than angle1, but less than angle1 + pi, return a
%  positive number; otherwise a negative number).  Default: false
% 

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id: angledist.m 13 2012-08-10 19:30:42Z dgolden $

%% Setup
if ~exist('str_rad_or_deg', 'var') || isempty(str_rad_or_deg)
	str_rad_or_deg = 'deg';
end
if ~exist('b_signed', 'var') || isempty(b_signed)
  b_signed = false;
end

%% Convert to radians if necessary
switch str_rad_or_deg
  case 'deg'
    angle1 = angle1*pi/180;
    angle2 = angle2*pi/180;
  case 'rad'
    % Do nothing
  otherwise
    error('Weird value for str_rad_or_deg (''%s'')', str_rad_or_deg);
end

%% Get the angle distance
dist = angle(exp(j*angle2)./exp(j*angle1));

%% Convert back to degrees if necessary
switch str_rad_or_deg
  case 'deg'
    dist = dist*180/pi;
end

%% Get abs of distance if necessary
if ~b_signed
  dist = abs(dist);
end
