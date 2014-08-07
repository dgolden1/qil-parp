function make_slice_movie(slices, t, x_coord_mm, y_coord_mm, output_filename, fig_title_prefix, varargin)
% Make a movie of a slice vs. time
% For a movie of a single slice, slices should be IxJxN
% For K slices, slices should be a cell array of slices

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
if ~exist('output_filename', 'var') || isempty(output_filename)
  output_filename = '~/temp/movie.avi';
end

p = inputParser;
p.addParamValue('roi_mask', []);
p.addParamValue('roi_poly', []);
p.addParamValue('lesion_center_mm', []);
p.addParamValue('h_fig', []);
p.parse(varargin{:});
roi_mask = p.Results.roi_mask;
roi_poly = p.Results.roi_poly;
lesion_center_mm = p.Results.lesion_center_mm;
h_fig = p.Results.h_fig;

%% Make movie
if isempty(h_fig)
  h_fig = figure;
  if iscell(slices)
    figure_grow(gcf, 1.5^length(slices), 1);
  end
end

movie_fofo(@(idx) make_movie_frame(idx, slices, x_coord_mm, y_coord_mm, fig_title_prefix, t, roi_mask, roi_poly, lesion_center_mm), ...
  length(t), 'framerate', 5, 'output_filename', output_filename, 'h_fig', h_fig);

function make_movie_frame(idx, slices, x_coord_mm, y_coord_mm, fig_title_prefix, t, roi_mask, roi_poly, lesion_center_mm)
%% Function: make one movie frame from a slices stack

clf(gcf);
if ~iscell(slices)
  slices = {slices};
end
img_diameter = 50; % mm

if ~isempty(roi_mask)
  roi_x_center = x_coord_mm(round(mean([find(any(roi_mask, 1), 1, 'first') find(any(roi_mask, 1), 1, 'last')])));
  roi_y_center = y_coord_mm(round(mean([find(any(roi_mask, 2), 1, 'first') find(any(roi_mask, 2), 1, 'last')])));

  cax = quantile(slices{1}(mask_2d_nd(slices{1}, roi_mask)), [0.01 0.99]);
else
  cax = quantile(slices{1}(:), [0.01 0.99]);
end

delete(findall(gcf, 'tag', 'img_title')); % Titles persist even after calling cla() for some reason
for kk = 1:length(slices)
  s = super_subplot(1, length(slices), kk);
  cla;
  imagesc(x_coord_mm, y_coord_mm, slices{kk}(:,:,idx));
  
  axis xy equal off

  if ~isempty(roi_poly)
    hold on;
    plot(roi_poly.img_x_mm([1:end 1]), roi_poly.img_y_mm([1:end 1]), 'r-', 'markersize', 8);
    xlim(roi_x_center + [-1 1]*img_diameter/2);
    ylim(roi_y_center + [-1 1]*img_diameter/2);
  else
    axis tight
  end
  if ~isempty(lesion_center_mm)
    hold on;
    plot(lesion_center_mm(1), lesion_center_mm(2), 'ro', 'markerfacecolor', 'w', 'markersize', 10);
  end
  
  caxis(cax);
  
  h = title([fig_title_prefix sprintf('  t=%06.0f', t(idx))]);
  set(h, 'tag', 'img_title');
end

colormap gray;
increase_font;
