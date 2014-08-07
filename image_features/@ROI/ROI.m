classdef ROI
  % A region of interest
  
  % By Daniel Golden (dgolden1 at stanford dot edu) September 2012
  % $Id: ROI.m 291 2013-05-31 23:45:56Z dgolden $
  
  properties
    ROIPolyX % ROI x coordinate in pixels
    ROIPolyY % ROI y coordinate in pixels
    ImageXmm % Image x coordinate in mm
    ImageYmm % Image y coordinate in mm
    bPlotInmm = false; % Make plots in mm instead of pixels
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method
    ROIMask
    ImageSize % 2-element vector containing size of original image
    bIsSpline % True if ROI has been converted to spline
  end
  
  properties (Access=protected)
    ROINonSplinePolyX; % If ROI has been converted to a spline, the old ROI is saved here
    ROINonSplinePolyY; % If ROI has been converted to a spline, the old ROI is saved here
    ManualROIMask; % The ROI mask that has been set manually
  end
  
  methods
    function obj = ROI(ROIPolyX, ROIPolyY, ImageXmm, ImageYmm, varargin)
      % ROI(ROIPolyX, ROIPolyY, ImageXmm, ImageYmm, 'param', value, ...)
      % 
      % INPUTS
      % ROIPolyX, ROIPolyY: vectors of X and Y coordinates of the ROI, in pixels
      % ImageXmm, ImageYmm: vectors of X and Y coordinates of the pixels of the source
      %  image, in mm. E.g., if the image was called 'img', you would plot it like:
      %  imagesc(ImageXmm, ImageYmm, img)
      %
      % PARAMETERS
      % ROIMask: supply this and leave ROIPolyX and ROIPolyY blank to just set an ROI
      % mask
      % ROIMaskMethod: one of 'bwboundaries' (default) or 'direct' (see documentation
      %  for ROI.SetMask)
      % b_allow_multiple_rois: True to allow multiple ROIs to be returned if there are
      %  multiple distinct regions in the mask; otherwise, just return the biggest region
      % b_store_mask: true to store the mask in the ROI object (vastly increases memory
      %  usage but reduces computation time)
      
      if nargin == 0
        return;
      end
      
      % Parse input arguments
      p = inputParser;
      p.addParamValue('ROIMask', []);
      p.addParamValue('ROIMaskMethod', 'bwboundaries');
      p.addParamValue('b_allow_multiple_rois', false);
      p.addParamValue('b_store_mask', false);
      p.parse(varargin{:});
      
      obj.ImageXmm = ImageXmm;
      obj.ImageYmm = ImageYmm;
      
      if length(ROIPolyX) ~= length(ROIPolyY)
        error('ROIPolyX and ROIPolyY must be the same length');
      end
      if ~isempty(ImageXmm) && (any(ROIPolyX < 0 | ROIPolyX > (length(ImageXmm) + 1)) || any(ROIPolyY < 0 | ROIPolyY > (length(ImageYmm) + 1)))
        warning('Some ROI coordinates are outside the bounds of the image');
      end
      if ~isempty(p.Results.ROIMask)
        % Caller supplied a mask instead of a polygon
        if ~isempty(ROIPolyX) || ~isempty(ROIPolyY)
          error('If ROIMask is supplied, ROIPolyX and ROIPolyY must be empty');
        end
        
        obj = SetMask(obj, p.Results.ROIMask, 'method', p.Results.ROIMaskMethod, 'b_allow_multiple_rois', p.Results.b_allow_multiple_rois);
      else
        obj.ROIPolyX = ROIPolyX;
        obj.ROIPolyY = ROIPolyY;
      end
      if p.Results.b_store_mask
        obj = StoreMask(obj);
      end
    end
    
    function [ROIPolyXmm, ROIPolyYmm] = GetROIPolymm(obj)
      % Get the ROI poly coordinates in mm
      
      [ROIPolyXmm, ROIPolyYmm] = px_to_mm(obj.ImageXmm, obj.ImageYmm, obj.ROIPolyX, obj.ROIPolyY);
    end
    
    function value = get.ROIMask(obj)
      if ~isempty(obj.ManualROIMask)
        value = obj.ManualROIMask;
      else
        if length(obj.ROIPolyX) ~= length(obj.ROIPolyY)
          error('Lengths of ROIPolyX and ROIPolyY differ');
        end

        value = poly2mask(obj.ROIPolyX, obj.ROIPolyY, obj.ImageSize(1), obj.ImageSize(2));
      end
    end
    
    function value = get.ImageSize(obj)
      value = [length(obj.ImageYmm), length(obj.ImageXmm)];
    end
    
    function value = get.bIsSpline(obj)
      value = ~isempty(obj.ROINonSplinePolyX);
    end
  end
  
  methods (Static)
    obj = CreateROI(varargin);
    obj = CombineROIs(varargin);
  end
end
