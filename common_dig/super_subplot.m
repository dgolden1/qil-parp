function h = super_subplot(nrows, ncols, idx, hspace, vspace, hmargin, vmargin, str_idx_type)
% h = super_subplot(nrows, ncols, idx, hspace, vspace, hmargin, vmargin, str_idx_type)
% Dan's super subplot function
% 
% Works the same as subplot, but now you can specify vspace and hspace, the
% vertical and horizontal spacing between adjacent plots, in normalized
% figure units
% 
% vmargin and hmargin 2-element vectors specifying are the margins on the
% bottom, top, left and right of the figure, also in normalized
% figure units. 0.1 is an OK size when using 16-pt font
% 
% if str_idx_type is 'subplot' (default), then indices go first across columns, then
% down rows (like in the subplot function).  If it's 'matrix', then indices
% go first down rows, then across columns.
% 
% This spacing is FIXED, so don't be surprised if your titles and whatever
% smash into adjacent plots.  Getting what you want out of this function is
% generally an exercise in trial and error.
% 
% You can debug the positioning by running set(gcf, 'units', 'normalized'),
% clicking on the figure, and running get(gcf, 'CurrentPoint'), which will
% give the location of the click in normalized figure units.

% By Daniel Golden (dgolden1 at stanford dot edu) April 2010
% $Id: super_subplot.m 13 2012-08-10 19:30:42Z dgolden $

%% Arguments
if ~exist('vspace', 'var') || isempty(vspace)
	vspace = 0;
end
if ~exist('hspace', 'var') || isempty(hspace)
	hspace = 0;
end
if ~exist('vmargin', 'var') || isempty(vmargin)
	vmargin = [0 0];
end
if isscalar(vmargin)
  vmargin = [vmargin vmargin];
end
if ~exist('hmargin', 'var') || isempty(hmargin)
	hmargin = [0 0];
end
if isscalar(hmargin)
  hmargin = [hmargin hmargin];
end
if ~exist('str_idx_type', 'var') || isempty(str_idx_type)
  str_idx_type = 'subplot';
end


%% Determine position
switch lower(str_idx_type)
  case 'matrix'
    thisrow = 1 + mod(idx-1, nrows);
    thiscol = 1 + floor((idx-1)/nrows);
  otherwise
    thiscol = 1 + mod(idx-1, ncols);
    thisrow = 1 + floor((idx-1)/ncols);
end

% There is a total of (1 - sum(hmargin)) horizontal space and (1 -
% sum(vmargin)) vertical space for plots
% Each plot gets (1 - sum(hmargin))/ncols horizontal space and (1 -
% sum(vmargin))/nrows vertical space
% Of this space, (ncols - 1)*hspace and (nrows - 1)*vspace is available for
% the plots, and the rest is margin between adjacent plots

% Allow for multiple specified slots, just like subplot (i.e., subplot(1, 2:4))
width1 = (1 - sum(hmargin))/ncols - hspace*(ncols - 1)/ncols; % Width of a single cell
height1 = (1 - sum(vmargin))/nrows - vspace*(nrows - 1)/nrows; % Height of a single cell

n = length(idx); % n > 1 if this axis is taking up multiple slots
if n > 1 && all(diff(thisrow) == 0) && all(diff(thiscol) == 1)
  width = (1 - sum(hmargin))/ncols*n - hspace*(ncols - length(n))/ncols;
else
  width = width1;
end
if n > 1 && all(diff(thisrow) == 1) && all(diff(thiscol) == 0)
  height = (1 - sum(vmargin))/nrows*n - vspace*(nrows - length(n))/nrows;
else  
  height = height1;
end


left = min(hmargin(1) + (thiscol - 1)*(width1 + hspace));
bottom = min(vmargin(1) + (nrows - thisrow)*(height1 + vspace));

pos = [left bottom width height];

h = axes('position', pos);
