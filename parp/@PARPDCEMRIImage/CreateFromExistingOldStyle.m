function obj = CreateFromExistingOldStyle(patient_id, str_pre_or_post_chemo)
% Create a PARPDCEMRIImage object from an existing files that were created using
% get_and_combine_slices.m

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

[slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id, str_pre_or_post_chemo);
slice = load(slice_filename);

obj = PARPDCEMRIImage(patient_id, str_pre_or_post_chemo, slice.slices, slice.info, slice.x_mm, slice.y_mm, slice.z_mm, slice.start_datenum, slice.t);

if isfield(slice, 'slices_unregistered')
  obj.ImageStackUnregistered = slice.slices_unregistered;
end

if exist(roi_filename, 'file')
  roi = load(roi_filename);
  [roi_x, roi_y] = mm_to_px(obj.XCoordmm, obj.YCoordmm, roi.roi_poly.img_x_mm, roi.roi_poly.img_y_mm);
  obj.MyROI = ROI(roi_x, roi_y, obj.XCoordmm, obj.YCoordmm);
end

obj = CreateEmpiricalMaps(obj);

if exist(pk_filename, 'file');
  pk = load(pk_filename);
  obj.IFKtrans = MakeIFFromVector(obj, pk.ktrans, 'ktrans', 'Ktrans');
  obj.IFKep = MakeIFFromVector(obj, pk.kep, 'kep', 'Kep');
  obj.IFVe = MakeIFFromVector(obj, pk.ve, 've', 'Ve');
  obj.PKModel = pk.model;
end

1;
