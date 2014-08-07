function varargout = title_arbitrary_pos(title_str, varargin)
% Make a figure title in an arbitrary position by creating a new, invisible axis
% h = title_arbitrary_pos(title_str, varargin)
% 
% PARAMETERS
% y: y location of center of title (in figure units) (default: 0.91, looks good on a
% normal-height figure with normal-height axis, after applying increase_font)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2013
% $Id: title_arbitrary_pos.m 339 2013-07-11 00:06:11Z dgolden $


%% Parse input arguments
p = inputParser;
p.addParamValue('y', 0.91);
p.parse(varargin{:});

%% Make axis
ha = axes('Position', [0, p.Results.y, 1, 0.01]);
axis off;
title(ha, title_str);

%% Return axis
if nargout > 0
  varargout{1} = ha;
end