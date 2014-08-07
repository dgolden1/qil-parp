function r = get_radius_on_rectangle(xlim, ylim, theta)
% r = get_radius_on_rectangle(xlim, ylim, theta)
% 
% Given the coordinates of a rectangle, and an angle theta, return
% the radius from the origin to the edge of the rectangle at that angle
% 
% xlim and ylim are two-element vectors
% theta in radians

% By Daniel Golden (dgolden1 at stanford dot edu) March 2010
% $Id: get_radius_on_rectangle.m 2 2012-08-02 23:59:40Z dgolden $

% Get theta at corners
corner_theta = mod(atan2([ylim(2) ylim(2) ylim(1) ylim(1)], [xlim(2) xlim(1) xlim(1) xlim(2)]), 2*pi);
if ylim(2) > 0 && angle_is_between(corner_theta(1), corner_theta(2), theta, 'rad')
	r = ylim(2)/sin(theta);
elseif xlim(1) < 0 && angle_is_between(corner_theta(2), corner_theta(3), theta, 'rad')
	r = xlim(1)/cos(theta);
elseif ylim(1) < 0 && angle_is_between(corner_theta(3), corner_theta(4), theta, 'rad')
	r = ylim(1)/sin(theta);
elseif xlim(2) > 0 && angle_is_between(corner_theta(4), corner_theta(1), theta, 'rad')
	r = xlim(2)/cos(theta);
else
	error('Theta must lie in a region with values (theta = %0.0f deg, xl = [%f, %f], yl = [%f, %f]', ...
		theta*180/pi, xlim(1), xlim(2), ylim(1), ylim(2));
end

assert(r > 0);
