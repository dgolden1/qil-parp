function CreateMovie(obj, varargin)
% Make a movie of a slice vs. time

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('output_filename', fullfile(qilcasestudyroot, 'parp', 'registration_movies', obj.ImageTag, sprintf('%s_%s_movie.avi', obj.PatientIDStr, obj.ImageTag)));
p.addParamValue('b_include_unregistered', true);
p.addParamValue('h_fig', []);
p.parse(varargin{:});

%% Make movie
if isempty(p.Results.h_fig)
  h_fig = figure;
else
  h_fig = p.Results.h_fig;
end
sfigure(h_fig);

movie_fofo(@(idx) make_movie_frame(idx, obj, p.Results.b_include_unregistered), length(obj.Time), 'framerate', 5, 'output_filename', p.Results.output_filename, 'h_fig', h_fig);

function make_movie_frame(idx, obj, b_include_unregistered)
%% Function: make one movie frame from a slices stack

clf(gcf);
if b_include_unregistered && ~isempty(obj.ImageStackUnregistered)
  slices = {obj.ImageStackUnregistered, obj.ImageStack};
else
  slices = {obj.ImageStack, zeros(size(obj.ImageStack))};
end

img_diameter = 50; % mm

if ~isempty(obj.MyROI)
  roi = obj.MyROI;
  roi.bPlotInmm = true;

  cax = quantile(flatten(obj.GetROIPixels), [0.01 0.99]);
else
  roi = [];
  cax = quantile(slices{1}(:), [0.01 0.99]);
end

delete(findall(gcf, 'tag', 'img_title')); % Titles persist even after calling cla() for some reason
for kk = 1:length(slices)
  s = super_subplot(1, length(slices), kk);
  cla;
  imagesc(obj.XCoordmm, obj.YCoordmm, slices{kk}(:,:,idx));
  
  axis xy equal off

  if ~isempty(roi)
    hold on;
    PlotROI(roi, 'b_zoom_to_roi', false, 'b_length_marker', false, 'roi_color', 'r');
  end
  xlim(obj.LesionCenter(1) + [-1 1]*img_diameter/2);
  ylim(obj.LesionCenter(2) + [-1 1]*img_diameter/2);
  
  if ~isempty(obj.LesionCenter)
    hold on;
    plot(obj.LesionCenter(1), obj.LesionCenter(2), 'ro', 'markerfacecolor', 'w', 'markersize', 10);
  end
  
  caxis(cax);
  
  h = title(sprintf('Patient %s\nt=%06.0f', obj.PatientIDStr, obj.Time(idx)));
  set(h, 'tag', 'img_title');
end

colormap gray;
increase_font;
