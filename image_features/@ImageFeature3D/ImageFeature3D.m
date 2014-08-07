classdef ImageFeature3D
  % An object to extract image features from a 3D volume
  
  % By Daniel Golden (dgolden1 at stanford dot edu) January 2013
  % $Id$
  
  properties
    PatientID

    ImageVolume
    ImageName
    ImagePrettyName
    SpatialXCoords
    SpatialYCoords
    SpatialZCoords
    SpatialCoordUnits
    
    MyROI3D
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method
    
    SpatialResInPlane % Spatial resolution (in SpatialCoordUnits) in X and Y directions
    SpatialResOutPlane % Spatial resolution (in SpatialCoordUnits) in Z direction
  end
  
  methods
    function obj = ImageFeature3D(image_volume, image_name, patient_id, varargin)
      if nargin == 0
        return;
      end
      
      p = inputParser;
      p.addParamValue('roi_3d', []);
      p.addParamValue('spatial_x_coords', 1:size(image_volume, 2));
      p.addParamValue('spatial_y_coords', 1:size(image_volume, 1));
      p.addParamValue('spatial_z_coords', 1:size(image_volume, 3));
      p.addParamValue('spatial_coord_units', 'Pixels');
      p.parse(varargin{:});
      
      obj.ImageVolume = image_volume;
      obj.ImageName = sanitize_struct_fieldname(image_name);
      obj.ImagePrettyName = strrep(image_name, '_', ' ');
      obj.PatientID = patient_id;
      
      obj.SpatialXCoords = p.Results.spatial_x_coords;
      obj.SpatialYCoords = p.Results.spatial_y_coords;
      obj.SpatialZCoords = p.Results.spatial_z_coords;
      obj.SpatialCoordUnits = p.Results.spatial_coord_units;
      
      obj.MyROI3D = p.Results.roi_3d;
    end
    
    function value = get.SpatialResInPlane(obj)
      res_x = abs(diff(obj.SpatialXCoords(1:2)));
      res_y = abs(diff(obj.SpatialYCoords(1:2)));
      if abs(res_x - res_y)/mean([res_x, res_y]) > 0.01
        warning('X and Y resolution differ by more than 1%');
      end
      
      value = mean([res_x, res_y]);
    end
    
    function value = get.SpatialResOutPlane(obj)
      value = abs(diff(obj.SpatialZCoords(1:2)));
    end
  end
end
