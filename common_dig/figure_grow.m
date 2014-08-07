function figure_grow(h, x_grow_factor, y_grow_factor)
% figure_grow(h, x_grow_factor, y_grow_factor)
% Grow a figure to make it wider and/or taller (affects visual and print size)
% Ex: if x_grow_factor = 2, then figure h will end up twice as wide as it
% was
% 
% If you don't enter x_grow_factor or y_grow_factor, the figure will be
% resized to the default value
% 
% See also figure_squish (soon to be obsolete)

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id: figure_grow.m 13 2012-08-10 19:30:42Z dgolden $

error(nargchk(0, 3, nargin));

if ~exist('h', 'var')
	h = gcf;
end

if ~exist('x_grow_factor', 'var')
	bDefaultSize = true;
else
	if ~exist('y_grow_factor', 'var')
		y_grow_factor = x_grow_factor;
	end
	
	bDefaultSize = false;
end


% Change display size
u = get(h, 'units');
set(h, 'units', 'pixels');
position = get(h, 'position');
if bDefaultSize
	set(h, 'position', [position(1:2), 560, 420]);
else
	set(h, 'position', [position(1:2), position(3)*x_grow_factor, position(4)*y_grow_factor]);
end

% Change print size too
set(h, 'units', 'inches');
u_paper = get(h, 'paperunits');
set(h, 'paperunits', 'inches');

pos_inches = get(h, 'position');
set(h, 'paperposition', [0 0 pos_inches(3:4)]);
set(h, 'papersize', pos_inches(3:4));

% Return units to original 
set(h, 'units', u);
set(h, 'paperunits', u_paper);
