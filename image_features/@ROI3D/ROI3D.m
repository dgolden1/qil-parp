classdef ROI3D
  % A 3D region of interest, defined as a collection of 2D ROI objects
  
  % By Daniel Golden (dgolden1 at stanford dot edu) January 2013
  % $Id$
  
  properties
    ROIs % 2D ROIs
    ROIZValues % z values of ROIs in PIXELS
    ImageZmm
  end
  
  properties(SetAccess = immutable)
    ROIMask % 3D ROI Mask
  end
  
  properties(Dependent)
    ImageXmm % Volume x coordinate in mm
    ImageYmm % Volume y coordinate in mm
    bPlotInUnits % Make plots in mm instead of pixels
  end
  
  methods
    function obj = ROI3D(rois_2d, rois_2d_zvals, image_z_mm)
      % obj = ROI3D(rois_2d, rois_2d_zvals, image_z_mm)
      % Create an ROI3D object from a collection of 2D ROI objects
      % rois_2d_zvals are indices into image_z_mm, and are in units of PIXELS (or
      %  indices), not mm
      
      if nargin == 0
        return;
      end
      
      obj.ROIs = rois_2d;
      obj.ROIZValues = rois_2d_zvals;
      obj.ImageZmm = image_z_mm;
      %obj.ROIMask = GetROIMask(obj); % Massively increases ROI file size, possibly to 10s of MB
    end
    
    function value = get.ImageXmm(obj)
      if isempty(obj.ROIs)
        value = [];
      else
        value = obj.ROIs(1).ImageXmm;
      end
    end
    
    function obj = set.ImageXmm(obj, value)
      if isempty(obj.ROIs)
        return;
      end
      
      for kk = 1:length(obj.ROIs)
        obj.ROIs(kk).ImageXmm = value;
      end
    end
    
    function value = get.ImageYmm(obj)
      if isempty(obj.ROIs)
        value = [];
      else
        value = obj.ROIs(1).ImageYmm;
      end
    end
    
    function obj = set.ImageYmm(obj, value)
      if isempty(obj.ROIs)
        return;
      end
      
      for kk = 1:length(obj.ROIs)
        obj.ROIs(kk).ImageYmm = value;
      end
    end
    
    function value = get.bPlotInUnits(obj)
      value = obj.ROIs(1).bPlotInUnits;
    end
    
    function obj = set.bPlotInUnits(obj, value)
      for kk = 1:length(obj.ROIs)
        obj.ROIs(kk).bPlotInUnits = value;
      end
    end
  end
end
