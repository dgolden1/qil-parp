function [glcm_props, glcm] = get_glcm_properties(img, grayco_offsets, quantiles, numlevels)
% Get GLCM properties averaged across the 8-neighborhood
% [glcm_props, glcm] = get_glcm_properties(img, grayco_offsets, quantiles, numlevels)
% 
% Regions outside the ROI should be set to NaN
% 
% If grayco_offsets is not given, it defaults to the 8-neighborhood

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
if ~exist('grayco_offsets', 'var') || isempty(grayco_offsets)
  % Use the 8-neighborhood
  grayco_offsets = [0 1; -1 1; -1 0; -1 -1];
end
if ~exist('quantiles', 'var') || isempty(quantiles)
  quantiles = [0.01 0.99];
end
if ~exist('numlevels', 'var') || isempty(numlevels)
  numlevels = 8;
end


%% Get properties for each angle
s = warning('off', 'Images:graycomatrix:scaledImageContainsNan'); % We know the image has NaNs
glcm = graycomatrix(img, 'Offset', grayco_offsets, 'graylimits', quantile(img(:), quantiles), 'NumLevels', numlevels, 'symmetric', true);
glcm_props_all = graycoprops(glcm);

%% Average across angles
fn = fieldnames(glcm_props_all);
for kk = 1:length(fn)
  glcm_props.(fn{kk}) = mean(glcm_props_all.(fn{kk}));
end

warning(s.state, 'Images:graycomatrix:scaledImageContainsNan');
