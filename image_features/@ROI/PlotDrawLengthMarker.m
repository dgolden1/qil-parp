function PlotDrawLengthMarker(obj, varargin)
% Draw a length marker under the image ROI
% Always draws a maker of length 10 mm

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id: PlotDrawLengthMarker.m 181 2013-02-08 23:58:21Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('line_length', 10);
p.addParamValue('line_color', 'r');
p.parse(varargin{:});

%% Draw line
line_length_px = p.Results.line_length*abs((obj.ImageSize(2) - 1))/abs(diff(obj.ImageXmm([1 end])));

hold on;

xl = xlim;
yl = ylim;
x_center = xl(1) + diff(xl)/2;
line_y_val = yl(1) + 0.9*diff(yl);

% Convert to mm if necessary
if obj.bPlotInmm
  line_length = line_length_px*diff(obj.ImageXmm(1:2));
else
  line_length = line_length_px;
end

h(1) = plot(x_center + line_length/2*[-1 1], line_y_val*[1 1], '-', 'color', p.Results.line_color, 'linewidth', 2);
h(2) = text(x_center, line_y_val, sprintf('%0.0f mm', p.Results.line_length), ...
  'color', p.Results.line_color, 'horizontalalignment', 'center', 'verticalalignment', 'top', 'fontweight', 'bold');
set(h, 'tag', 'length_marker');
