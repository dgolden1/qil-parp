function [xl, yl, zl] = GetBoundaries(obj, varargin)
% Get ROI boundaries (in pixels)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('zoom_factor', 1); % Values > 1 zoom out
p.addParamValue('b_mm', false);
p.parse(varargin{:});

%% Get max boundaries of all slices
xl_vec = nan(length(obj.ROIs), 2);
yl_vec = nan(length(obj.ROIs), 2);
for kk = 1:length(obj.ROIs)
  [xl_vec(kk,:), yl_vec(kk,:)] = GetBoundaries(obj.ROIs(kk));
end

xl = [min(xl_vec(:,1)), max(xl_vec(:,2))];
yl = [min(yl_vec(:,1)), max(yl_vec(:,2))];

zl = [min(obj.ROIZValues) max(obj.ROIZValues)];

%% Zoom out
xl = mean(xl) + diff(xl)/2*[-1 1]*p.Results.zoom_factor;
yl = mean(yl) + diff(yl)/2*[-1 1]*p.Results.zoom_factor;
zl = mean(zl) + diff(zl)/2*[-1 1]*p.Results.zoom_factor;

% Keep bounds within the border of the image
xl = max(min(xl, length(obj.ImageXmm)), 1);
yl = max(min(yl, length(obj.ImageYmm)), 1);
zl = max(min(zl, length(obj.ImageZmm)), 1);

%% Convert to mm
if p.Results.b_mm
  [xl, yl] = px_to_mm(obj.ImageXmm, obj.ImageYmm, xl, yl);
  zl = px_to_mm(obj.ImageZmm, obj.ImageYmm, zl, []);
end
