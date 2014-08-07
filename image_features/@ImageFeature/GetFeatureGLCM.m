function [feature_set, glcm] = GetFeatureGLCM(obj, varargin)
% Get GLCM properties averaged across the 8-neighborhood
% 
% PARAMETERS
% grayco_offsets: pixel neighborhood (default: [0 1; -1 1; -1 0; -1 -1] -- for a
%  symmetric matrix, this is the eight-neighborhood)
% quantiles: the upper and lower limits of the gray level range to examine when
%  determining the edge boundaries (default: [0.01 0.99])
% numlevels: number of gray levels (default: 8)
% edge_method: the method of determining edge boundaries. Options include:
%  'linear' (default): edges are chosen linearly from the lowest to the highest gray
%   level
%  'equal': bins are equalized
%  'boxcox': use Matlab's built-in boxcox function to transform the pixel values, and
%    then use linear edges
%  if a vector, then bin edges will be fixed at the given values; if the vector is has a
%   length of 2, then the edges are interpreted as outer edges, and the remaining edges
%   will be linearly interpolated between these outer edges
% img_resize_scale: factor by which to reduce image size (should be < 1)


% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: GetFeatureGLCM.m 258 2013-05-01 16:47:16Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('grayco_offsets', [0 1; -1 1; -1 0; -1 -1]);
p.addParamValue('quantiles', [0.01 0.99]);
p.addParamValue('numlevels', 8);
p.addParamValue('edge_method', 'linear');
p.addParamValue('img_resize_scale', 1);
p.parse(varargin{:});

%% Get properties for each angle
% Account for empty image or missing ROI
if isempty(obj.Image)
  fn = {'Contrast', 'Correlation', 'Energy', 'Homogeneity'};
  for kk = 1:length(fn)
    glcm_props_all.(fn{kk}) = nan(1, 4);
  end
else
  if p.Results.img_resize_scale > 1
    error('img_resize_scale must be less than 1');
  elseif p.Results.img_resize_scale < 1
    obj = ResizeImage(obj, p.Results.img_resize_scale);
  end
  
  img = GetImageNanOutsideROI(obj);
  
  % Transform the image to implement the requested edge_method
  if ischar(p.Results.edge_method)
    % Bin edges are determined based on this image's properties
    
    % Threshold the image so that all values lie between the requested quantiles
    img_quantiles = quantile(img(:), p.Results.quantiles);
    img(img < img_quantiles(1)) = img_quantiles(1);
    img(img > img_quantiles(2)) = img_quantiles(2);

    switch p.Results.edge_method
      case 'linear'
        % Do nothing
        % [~, bin] = histc(img, linspace(min(img(:)), max(img(:)), p.Results.numlevels + 1));
        % bin(bin == max(bin(:))) = max(bin(:)) - 1; % Shove the few values on the rightmost bin edge into the rightmost bin
      case 'equal'
        [~, bin] = histc(img, quantile(img(:), linspace(0, 1, p.Results.numlevels + 1)));
        bin(bin == max(bin(:))) = max(bin(:)) - 1; % Shove the few values on the rightmost bin edge into the rightmost bin
        img(~isnan(img)) = bin(~isnan(img));
      case 'boxcox'
        img_scaled = -(img - min(img(:)))/(max(img(:)) - min(img(:))) + 1.01;
        img_boxcox = -reshape(boxcox(img_scaled(:)), size(img_scaled));
        img_boxcox(isnan(img)) = nan;
        img = img_boxcox;
    end
    
    graylimits = quantile(img(:), [0 1]);
  else
    % Using user-specified bin edges
    
    if length(p.Results.edge_method) == 2
      % Given edges are the outer edges; linearly interpolate the remaining edges in
      % between the outer edges
      bin_edges = linspace(p.Results.edge_method(1), p.Results.edge_method(2), p.Results.numlevels + 1);
      num_levels = p.Results.numlevels;
    elseif length(p.Results.edge_method) ~= p.Results.numlevels + 1
      error('Length of bin edges (%d) should equal num_edges (%d) + 1', length(p.Results.edge_method), p.Results.num_edges);
    else
      bin_edges = p.Results.edge_method;
      num_levels = length(bin_edges) - 1;
    end
    
    [~, bin] = histc(img(:), bin_edges);
    bin(img(:) >= bin_edges(end)) = length(bin_edges) - 1; % Shove values on or above the highest bin into the highest bin
    bin(img(:) <= bin_edges(1)) = 1; % Shove values on or below the lowest bin into the lowest bin
    
    assert(all(bin(~isnan(img)) ~= 0)); % There should be no non-nan image pixels that aren't assigned to a bin
    img(~isnan(img)) = bin(~isnan(img)); % Assign bin value to all non-nan image pixels
    
    graylimits = [1, length(bin_edges) - 1];
    
  end
  
  s = warning('off', 'Images:graycomatrix:scaledImageContainsNan'); % We know the image has NaNs
  glcm = graycomatrix(img, 'Offset', p.Results.grayco_offsets, 'graylimits', graylimits, 'NumLevels', p.Results.numlevels, 'symmetric', true);
  warning(s.state, 'Images:graycomatrix:scaledImageContainsNan');

  glcm_props_all = graycoprops(glcm);
end

glcm_props.patient_id = obj.PatientID;

%% Average across angles
fn = fieldnames(glcm_props_all);
for kk = 1:length(fn)
  % Rename fields to make them more compact
  switch fn{kk}
    case 'Contrast'
      short_fn = 'contrast';
    case 'Correlation'
      short_fn = 'corr';
    case 'Energy'
      short_fn = 'energy';
    case 'Homogeneity'
      short_fn = 'homog';
  end
  
  % output_fn = sprintf('%s_%s', short_fn, obj.ImageName);
  output_fn = short_fn;
  % pretty_name{kk} = sprintf('GLCM %s %s', fn{kk}, obj.ImagePrettyName);
  pretty_name{kk} = fn{kk};
      
  glcm_props.(output_fn) = mean(glcm_props_all.(fn{kk}));
end

%% Make feature set output object
if isempty(obj.ImageName)
  feature_category_name = 'glcm';
else
  feature_category_name = ['glcm_' obj.ImageName];
end

if isempty(obj.ImagePrettyName)
  feature_category_pretty_name = 'GLCM';
else
  feature_category_pretty_name = ['GLCM ' obj.ImagePrettyName];
end

feature_set = FeatureSet(glcm_props, pretty_name, feature_category_name, feature_category_pretty_name);
feature_cat = feature_set.FeatureCategoryName;

%% Add average value as a feature
if isempty(obj.MyROI)
  avg = nan;
else
  avg = mean(obj.Image(obj.MyROI.ROIMask));
end

feature_set = [feature_set, FeatureSet(avg, obj.PatientID, {'avg'}, {'Average'}, obj.ImageName, obj.ImagePrettyName)];
feature_set.FeatureCategoryName = feature_cat;

%% Add comment
if ischar(p.Results.edge_method)
  edge_method_str = p.Results.edge_method;
elseif isnumeric(p.Results.edge_method) && length(p.Results.edge_method) == 2
  edge_method_str = sprintf('[%0.0f %0.0f]', p.Results.edge_method);
end

feature_set.Comment = sprintf('GLCM quantiles=[%0.2f %0.2f], numlevels=%d, edge method=''%s'', resize scale=%0.2f', ...
  p.Results.quantiles, p.Results.numlevels, edge_method_str, p.Results.img_resize_scale);

1;
