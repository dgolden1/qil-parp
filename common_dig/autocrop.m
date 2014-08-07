function autocrop(h)
% Crop borders of image; useful for printing as a PDF, as 'print -dpdf
% whatever.pdf'

% By Daniel Golden April 2009
% $Id: autocrop.m 13 2012-08-10 19:30:42Z dgolden $

if ~exist('h', 'var')
	h = gcf;
end

% oldunits = get(h, 'Units');
% set(h, 'Units', 'Inches');
% pos = get(h, 'position');
% set(h, 'paperposition', [0 0 pos(3:4)]);
% set(h, 'papersize', pos(3:4));
% set(h, 'units', oldunits);

ppos = get(h, 'paperposition');
set(h, 'paperposition', [0 0 ppos(3:4)]);
set(h, 'papersize', ppos(3:4));
