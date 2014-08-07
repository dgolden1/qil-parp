function varargout = bar_by_edges(edges, Y, varargin)
% h = bar_by_edges(edges, Y, 'param', value, ...)
% 
% Plots a bar chart using patches.  The bars are defined by their
% edges, not their centers, which allows for bars with unequal widths
% 
% It must be true that length(edges) = length(y) + 1
% 
% PARAMETERS
% orientation: may be one of 'vertical', for a bar chart with vertical bars,
%  or 'horizontal', for a bar chart with horizontal bars
% color: bar face color
% baseline: lower edge of the bar (default: 0). Useful to set to a nonzero
%  value if the y-scale will be set to log

% By Daniel Golden (dgolden1 at stanford dot edu) January 2010
% $Id: bar_by_edges.m 294 2013-06-05 22:35:47Z dgolden $

%% Setup
p = inputParser;
p.addParamValue('orientation', 'vertical');
p.addParamValue('color', 'b');
p.addParamValue('baseline', 0);
p.parse(varargin{:});
orientation = p.Results.orientation;
color = p.Results.color;
baseline = p.Results.baseline;

if any(isnan(edges))
  error('Edges may not contain NaNs');
end
if any(isnan(Y))
  error('Y may not contain NaNs');
end

	
if length(edges) ~= length(Y) + 1
	error('length(y) + 1 (%d) must equal length(edges) (%d)', length(Y) + 1, length(edges));
end


%% Plot
x = zeros(length(edges)*3 - 2, 1);
y = zeros(length(edges)*3 - 2, 1);

x(1:3:end) = edges(1:end);
x(2:3:end) = edges(1:end-1);
x(3:3:end) = edges(2:end);

y(1:3:end) = baseline;
y(2:3:end) = Y;
y(3:3:end) = Y;

if strcmp(orientation, 'vertical')
	h = patch(x, y, color);
elseif strcmp(orientation, 'horizontal')
	h = patch(y, x, color);
else
	error('Invalid string for orientation: ''%s'', orientation');
end


%% Outputs
if nargout > 0
	varargout{1} = h;
end
