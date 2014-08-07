function get_pixel_perfusion_curve(h_ax, slices, x_mm, y_mm, z_mm, t, b_area)
% Plot perfusion curve for selected pixels of an image
% get_pixel_perfusion_curve(h_ax, slices, x_mm, y_mm, z_mm, t)
% 
% If b_area is false (default), select individual pixels; otherwise, choose
%  two points for an area, and all pixels are plotted

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if ~exist('b_area', 'var') || isempty(b_area)
  b_area = false;
end

[x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);

%% Get pixels
saxes(h_ax);
if b_area
  [x, y] = ginput(2);
else
  [x, y] = ginput;
end
if isempty(x) || (b_area && length(x) < 2)
  return
end

x_idx = interp1(x_coord_mm, 1:length(x_coord_mm), x, 'nearest');
y_idx = interp1(y_coord_mm, 1:length(y_coord_mm), y, 'nearest');

%% Process area
if b_area
  x_idx_corner = sort(x_idx);
  y_idx_corner = sort(y_idx);
  
  x_idx_vec = x_idx_corner(1):x_idx_corner(2);
  y_idx_vec = y_idx_corner(1):y_idx_corner(2);
  [x_idx, y_idx] = ndgrid(x_idx_vec, y_idx_vec);
end


for kk = 1:numel(x_idx)
  perf_curve(1:size(slices, 3), kk) = flatten(slices(y_idx(kk), x_idx(kk), :));
end

figure;
plot(t, perf_curve, 'o-');
xlabel('Sec');
ylabel('Value');
grid on;
if ~b_area
  legend(num2str((1:length(x)).'));
end
