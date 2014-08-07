function figure_squish(h, x_squish_factor, y_squish_factor)
% figure_squish(h, x_squish_factor, y_squish_factor)
% Squish a figure to make it less wide or tall (affects visual and print size)
% Ex: if y_squish_factor = 2, then figure h will end up half as tall as it
% was
% 
% If you don't enter x_squish_factor or y_squish_factor, the figure will be
% resized to the default value

% By Daniel Golden (dgolden1 at stanford dot edu) May 2008
% $Id: figure_squish.m 13 2012-08-10 19:30:42Z dgolden $

error(nargchk(0, 3, nargin));

if ~exist('h', 'var')
	h = gcf;
end

if ~exist('x_squish_factor', 'var')
	bDefaultSize = true;
else
	bDefaultSize = false;
end

% Change display size
u = get(h, 'units');
set(h, 'units', 'pixels');
position = get(h, 'position');
if bDefaultSize
	set(h, 'position', [position(1:2), 560, 420]);
else
	set(h, 'position', [position(1:2), position(3)/x_squish_factor, position(4)/y_squish_factor]);
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
