function obj = CreateROI(obj)
% Manually create ROI on image empirical map
% Overloads superclass because we grab the lesion center from the PARP spreadsheet
% and plot it when creating the ROI

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

% Get lesion center from spreadsheet
lesion_center_xy_mm = GetLesionCenterFromSpreadsheet(obj);
[lesion_center_xy(1), lesion_center_xy(2)] = mm_to_px(obj.XCoordmm, obj.YCoordmm, lesion_center_xy_mm(1), lesion_center_xy_mm(2));

% Call DCEMRIImage version of CreateROI with supplied lesion center
obj = CreateROI@DCEMRIImage(obj, lesion_center_xy);
