classdef ImageFeature
  % A class of image features, which are defined based on an image and an
  % ROI
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id: ImageFeature.m 347 2013-07-17 00:05:49Z dgolden $

  properties
    Image % Possibly a volume with time as the 3rd dimension
    ImageName % The struct-friendly name of the image
    ImagePrettyName % The display-friendly name of the image
    SpatialXCoords % In specialized units
    SpatialYCoords % Specialized units
    SpatialCoordUnits % Name of units
    PatientID % Patient ID as a string or number
    MyROI
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method

    % Pixels within ROI; either Nx1 for 2D image or NxK for 3D image whose
    % 3rd dimension (e.g., time) has length K
    ROIPixels
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method
    
    SpatialRes % Spatial units per pixel, in units of SpatialCoordUnits/px
  end
  
  methods
    function obj = ImageFeature(Image, ImageName, PatientID, varargin)
      if nargin == 0
        return;
      end
      
      % Parse additional inputs
      p = inputParser;
      p.addParamValue('ImageSizePx', []); % Must be given if input image is a vector of masked pixels
      p.addParamValue('ImagePrettyName', []);
      p.addParamValue('MyROI', ROI.empty);
      p.addParamValue('SpatialXCoords', 1:size(Image, 2));
      p.addParamValue('SpatialYCoords', (1:size(Image, 1)).');
      p.addParamValue('SpatialCoordUnits', 'Pixels');
      p.addParamValue('CommonResolution', []);
      p.parse(varargin{:});
      
      % Assign ROI poly
      obj.MyROI = p.Results.MyROI;
     
      if isvector(Image)
        % Image is values within the ROI mask
        if isempty(p.Results.ROIPolyX)
          error('Image given as ROI pixels, but not ROI given')
        end
        if isempty(p.Results.ImageSizePx)
          error('Image given as ROI pixels, but ImageSizePx not given');
        end
        if ~isempty(p.Results.CommonResolution)
          error('Resizing image to common resolution is not supported if ROI pixels are supplied');
        end
        
        % Make an empty image so that set.ROIPixels knows the proper size
        % of the image
        obj.Image = nan(size(p.Results.ImageSizePx));
        
        obj.ROIPixels = Image;
      else
        % Image is a 2D image
        obj.Image = Image;
      end
      obj.ImageName = sanitize_struct_fieldname(ImageName);
      obj.PatientID = PatientID;
      
      % Error checking
      if length(p.Results.SpatialXCoords) ~= size(Image, 2)
        error('Image and SpatialXCoords have mismatched dimensions');
      end
      if length(p.Results.SpatialYCoords) ~= size(Image, 1)
        error('Image and SpatialYCoords have mismatched dimensions');
      end
      if ~(isequal(p.Results.SpatialXCoords(:), (1:size(Image, 2)).') && isequal(p.Results.SpatialYCoords(:), (1:size(Image, 1)).')) && ...
          strcmp(p.Results.SpatialCoordUnits, 'Pixels')
        error('Custom SpatialXCoords and/or SpatialYCoords provided without custom SpatialCoordUnits');
      end
        
      % Assign other properties
      obj.SpatialXCoords = p.Results.SpatialXCoords;
      obj.SpatialYCoords = p.Results.SpatialYCoords;
      obj.SpatialCoordUnits = p.Results.SpatialCoordUnits;
      if isempty(p.Results.ImagePrettyName)
        obj.ImagePrettyName = ImageName;
      else
        obj.ImagePrettyName = p.Results.ImagePrettyName;
      end

      x_res = abs(diff(obj.SpatialXCoords(1:2))); % In image units/pixel
      y_res = abs(diff(obj.SpatialYCoords(1:2)));
      if abs(x_res - y_res)/min(x_res,y_res) > 0.2
        error('Pixels are not square');
      end
      
      % Resize image to common resolution
      if ~isempty(p.Results.CommonResolution)
        
        this_resolution = x_res;
        
        scale_factor = this_resolution/p.Results.CommonResolution;
        obj = ResizeImage(obj, scale_factor);
      end
    end
    
    function PlotSetAxesToSpatial(obj, h_ax)
      % Set the x- and y-axes of a plotted image to be in spatial coordinates instead of
      % pixels
      
      if ~exist('h_ax', 'var') || isempty(h_ax)
        h_ax = gca;
      end
      
      h_img = findobj(gca, 'type', 'image');
      set(h_img, 'XData', obj.SpatialXCoords, 'YData', obj.SpatialYCoords);
      axis on;
    end
    
    function roi_pixels = get.ROIPixels(obj)
      if isempty(obj.MyROI)
        roi_pixels = [];
        return;
      end
      
      roi_mask = obj.MyROI.ROIMask;
      
      % Copy ROI mask across 3rd image dimension if there is one
      roi_mask_rep = repmat(roi_mask, [1 1 size(obj.Image, 3)]);
      
      roi_pixels = obj.Image(roi_mask_rep);
      
      if ~ismatrix(obj.Image)
        % 3D volume
        roi_pixels = reshape(sum(roi_mask(:)), size(obj.Image, 3));
      end
    end
    
    function value = get.SpatialRes(obj)
      value = abs(diff(obj.SpatialXCoords(1:2)));
    end
    
    function obj = set.ROIPixels(obj, roi_pixels)
      roi_mask = obj.MyROI.ROIMask;
      if size(roi_pixels, 1) ~= sum(roi_mask)
        error('Number of ROI pixels must equal sum of ROI mask');
      end
      
      % Account for image with multiple slices
      roi_mask_nd = repmat(roi_mask, [1 1 size(obj.Image, 3)]);
      
      obj.Image = nan(size(roi_mask_nd));
      obj.Image(roi_mask) = roi_pixels(:);
    end
  end
end
