function new_obj = ResizeImage(obj, varargin)
% Resize image and MyROI

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Setup
p = inputParser;
p.addParamValue('b_remake_maps', true);
p.addParamValue('scale_factor', []);
p.addParamValue('new_pixel_spacing', []);
p.parse(varargin{:});

if ~xor(isempty(p.Results.scale_factor), isempty(p.Results.new_pixel_spacing))
  error('Exactly one of scale_factor or new_pixel_spacing must be defined');
end

%% Set scale factor
if ~isempty(p.Results.scale_factor)
  scale_factor = p.Results.scale_factor;
else
  scale_factor = obj.PixelSpacing/p.Results.new_pixel_spacing;
end

if scale_factor > 1
  error('ResizeImage:EnlargeImage', 'Scale factor is > 1 (%f)', scale_factor);
elseif abs(scale_factor - 1) < 1e-2
  new_obj = obj;
  return;
end

%% Resize image
[new_image_stack, new_x_coord_mm, new_y_coord_mm] = resize_image_and_coords(obj.ImageStack, obj.XCoordmm, obj.YCoordmm, scale_factor);

[new_dicom_x, new_dicom_y, new_dicom_z] = DCEMRIImage.GetDICOMCoords(new_x_coord_mm, new_y_coord_mm, obj.SliceCoordmm, obj.SlicePlane);

obj_class = class(obj);
switch obj_class
  case 'PARPDCEMRIImage'
    new_obj = PARPDCEMRIImage(obj.PatientID, obj.ImageTag, new_image_stack, obj.ImageInfo, new_dicom_x, new_dicom_y, new_dicom_z, obj.StartDatenum, obj.Time);
  otherwise
    error('Unable to resize object of class ''%s''', obj_class);
end

%% Resize ROI
if ~isempty(obj.MyROI)
  new_roi_poly_x = (obj.MyROI.ROIPolyX - 1)*scale_factor + 1;
  new_roi_poly_y = (obj.MyROI.ROIPolyY - 1)*scale_factor + 1;
  new_obj.MyROI = ROI(new_roi_poly_x, new_roi_poly_y, new_x_coord_mm, new_y_coord_mm);
end

%% Recreate maps
% Re-create the empirical kinetic maps and PK maps if they existed for the old
% object. Note that we don't bother setting the new ImageStackUnregistered
if ~isempty(obj.IFWashIn)
end

if ~isempty(obj.IFKtrans) && p.Results.b_remake_maps
  new_obj = CreateEmpiricalMaps(new_obj);
  new_obj = CreatePKMaps(new_obj);
elseif ~isempty(obj.IFKtrans) && ~p.Results.b_remake_maps
  % Just resize the existing maps
  IF_names = GetDefinedIFs(obj);
  for kk = 1:length(IF_names)
    new_obj.(IF_names{kk}) = ResizeImage(obj.(IF_names{kk}), scale_factor);
  end
end

1;
