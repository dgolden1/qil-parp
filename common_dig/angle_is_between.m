function bIsBetween = angle_is_between(angle1, angle2, angletest, str_rad_or_deg)
% bIsBetween = angle_is_between(angle1, angle2, angletest, str_rad_or_deg)
% Determine whether angletest is between the arc formed by angle1 and
% angle2 (including the endpoints)
% 
% str_rad_or_deg should be either 'rad' or 'deg'. It is 'deg' by default.

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id: angle_is_between.m 13 2012-08-10 19:30:42Z dgolden $

if ~exist('str_rad_or_deg', 'var') || isempty(str_rad_or_deg)
	str_rad_or_deg = 'deg';
end

ad = angledist(angle1, angle2, str_rad_or_deg);
ad1 = angledist(angle1, angletest, str_rad_or_deg);
ad2 = angledist(angle2, angletest, str_rad_or_deg);

if strcmp(str_rad_or_deg, 'deg')
	tol = 0.01;
else
	tol = 0.01*pi/180;
end

bIsBetween = (abs(ad1 + ad2 - ad) < tol); % Same as ad1 + ad2 == ad, but with some accounting for roundoff
