function h_ax = saxes(h_ax)
% SAXES  Changes axes handle (minus annoying focus-theft).
%
% Usage is identical to axes.
% See also axes

% By Daniel Golden (dgolden1 at stanford dot edu) May 2009
% $Id: saxes.m 13 2012-08-10 19:30:42Z dgolden $

if nargin>=1 
	if ishandle(h_ax)
		h_fig = get(h_ax, 'parent');
		set(h_fig, 'currentaxes', h_ax);
		sfigure(h_fig);
	else
		h_ax = axes(h_ax);
	end
else
	h_ax = axes;
end
