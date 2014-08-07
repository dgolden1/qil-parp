classdef ImageFeatureSet
  % A set of multiple, related ImageFeatures
  % The idea is that this might represent related image features from
  % DCE-MRI, such as PK Kep, Ktrans and ve, or empirical wash-in, wash-out
  % and AUC
  %
  % So far, I'm not sure it's worth implementing
  
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$
  
  properties
    ImageSet % Multiple related ImageFeature objects
    ImageBG % Background image when plots only color within the ROI
  end
  
  methods
    function PlotTiled(obj)
      % Plot each image in a separate panel using subplots
      
      
    end
    
    function PlotHSV(obj)
      % Combine two images together into an HSV plot
    end
  end
end

function [img, cax_map, img_original] = get_map_on_gray_bg(bg_img, roi_mask, image_map, cax_map)
%% Function: Get a jet map on a gray background image

%% Setup
if ~exist('cax_param', 'var') || isempty(cax_map)
  cax_map = quantile(image_map(:), [0.01 0.99]);
end

%% The grayscale image background
cax_bg = quantile(bg_img(roi_mask), [0.01 0.99]);

img_original = ind2rgb(gray2ind(mat2gray(bg_img, cax_bg)), gray(64));

%% Overlay image map
colors_param = ind2rgb(gray2ind(mat2gray(image_map, cax_map)), jet(64));
img = img_original;
img(repmat(roi_mask, [1 1 3])) = colors_param;

end
