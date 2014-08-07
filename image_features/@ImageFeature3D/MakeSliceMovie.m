function MakeSliceMovie(obj, varargin)
% Make a movie showing the slices of the 3D ImageFeature volume
% MakeSliceMovie(obj, 'param', value, ...)
% 
% PARAMETERS
% output_dir: (default: '~/temp')
% output_filename: (default: determined from patient id; must end in .avi)
% framerate: default: 10 for only ROI slices, 24 for entire volume
% cax: color axis (default: 1-99th percentile of ROI)
% b_zoom_to_roi: (default: true)
% b_only_roi_slices: (default: true)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('output_dir', '~/temp');
p.addParamValue('output_filename', '');
p.addParamValue('framerate', []);
p.addParamValue('cax', []);
p.addParamValue('b_zoom_to_roi', ~isempty(obj.MyROI3D));
p.addParamValue('b_only_roi_slices', ~isempty(obj.MyROI3D));
p.parse(varargin{:});

if isempty(p.Results.cax) && ~isempty(obj.MyROI3D)
  cax = quantile(GetROIPixels(obj), [0.01 0.99]);
elseif ~isempty(p.Results.cax)
  cax = p.Results.cax;
else
  cax = quantile(obj.ImageVolume(:), [0 1]);
end

if isempty(p.Results.framerate)
  if p.Results.b_only_roi_slices
    framerate = 10;
  else
    framerate = 24;
  end
else
  framerate = p.Results.framerate;
end

if p.Results.b_only_roi_slices
  kk_max = length(unique(obj.MyROI3D.ROIZValues));
else
  kk_max = size(obj.ImageVolume, 3);
end

%% Create movie
if isempty(obj.MyROI3D)
  bounds.xl = [1 size(obj.ImageVolume, 2)];
  bounds.yl = [1 size(obj.ImageVolume, 1)];
else
  [bounds.xl, bounds.yl] = GetBoundaries(obj.MyROI3D, 'zoom_factor', 2, 'b_mm', true);
end

if isempty(p.Results.output_filename)
  output_filename = fullfile(p.Results.output_dir, sprintf('image_feature_movie_%s.avi', obj.PatientID));
else
  [~, ~, ext] = fileparts(p.Results.output_filename);
  if isempty(ext)
    just_output_filename = [just_filename(p.Results.output_filename) '.avi'];
  elseif strcmp(ext, '.avi')
    just_output_filename = just_filename(p.Results.output_filename);
  else
    error('output_filename extension (%s) must be .avi', ext);
  end
  
  output_dir = fileparts(p.Results.output_filename);
  if isempty(output_dir)
    output_dir = p.Results.output_dir;
  end
  output_filename = fullfile(output_dir, just_output_filename);
end
  
movie_fofo(@(kk) plot_fcn(kk, obj, cax, bounds, p), kk_max, 'framerate', framerate, 'output_filename', output_filename);

function plot_fcn(kk, obj, cax, bounds, p)
%% Function: plotting function for movie_fofo

if p.Results.b_only_roi_slices
  slice_idx = kk + min(obj.MyROI3D.ROIZValues) - 1;
else
  slice_idx = kk;
end
IF2D = GetImageFeature2D(obj, 'z_pixel', slice_idx);

clf;
PlotImage(IF2D, 'b_spatial_coords', true, 'b_cax_from_roi', false, 'h_ax', gca);

if p.Results.b_zoom_to_roi
  xlim(bounds.xl);
  ylim(bounds.yl);
end

caxis(cax);
title(sprintf('Patient %s\n%s  Slice %0.2f %s', obj.PatientID, obj.ImagePrettyName, obj.SpatialZCoords(slice_idx), obj.SpatialCoordUnits));
c = colorbar;
% ylabel(c, 'HU');
increase_font;

1;
