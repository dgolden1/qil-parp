function force_close_all
% Force close all figures, even "protected" ones, like waitbars

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id: force_close_all.m 13 2012-08-10 19:30:42Z dgolden $

delete(findall(0, 'type', 'figure'))
