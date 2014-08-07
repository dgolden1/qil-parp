function obj = ConvertToSpline(obj)
% Convert polygonal ROI to spline

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: ConvertToSpline.m 185 2013-02-13 01:42:05Z dgolden $

%% Setup
if obj.bIsSpline
  error('ROI has already been converted to spline');
end

method = 'dan';
% method = 'jiajing';

% Save pre-spline X and Y values
obj.ROINonSplinePolyX = obj.ROIPolyX;
obj.ROINonSplinePolyY = obj.ROIPolyY;

%% Jiajing's method
if strcmp(method, 'jiajing')
  % Jiajing's method based on OsiriX code
  [new_x, new_y] = osirix_spline_interpolate(obj.ROIPolyX([1:end 1]), obj.ROIPolyY([1:end 1]));
  obj.ROIPolyX = new_x;
  obj.ROIPolyY = new_y;

  return;
end

%% Delete points that are too close to each other
% Points that are very close tend to make "loops" in the ROI after spline interpolation,
% and are probably the result of accidental clicks in OsiriX
x = obj.ROIPolyX(:);
y = obj.ROIPolyY(:);

dt = diff_2d(x, y);
median_dist = median(dt);
[min_dist, min_idx] = min(dt);
while min_dist < median_dist/5
  x(min_idx) = [];
  y(min_idx) = [];
  
  dt = diff_2d(x, y);
  median_dist = median(dt);
  [min_dist, min_idx] = min(dt);
end


%% Calculate spline
num_pts = 50;
t = 1:length(x);

% pp = csape([t, t(end)+1], [x([1:end 1]), y([1:end 1])].', 'periodic');
pp = csape([t, t(end)+1], [x([1:end 1]), y([1:end 1])].', 'periodic');
v = ppval(pp, linspace(t(1), t(end)+1, num_pts));

% vertices_spline = spline(t, [x([end 1:end 1]), y([end 1:end 1])].', linspace(1, length(t), num_pts));

%% Assign new coordinates
obj.ROIPolyX = v(1,:).';
obj.ROIPolyY = v(2,:).';


function dt = diff_2d(x, y)
%% Function: get Euclidian distances
% Get euclidian distances between adjacent points, and wrap around so length(dt) is the
% same as length(x) and length(y)

% Make values periodic
x = x([1:end 1]);
y = y([1:end 1]);

dt = sqrt(diff(x).^2 + diff(y).^2);
