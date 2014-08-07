function test_parp_dce_mri_image_class
% Test the PARPDCEMRIImage class

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: test_parp_dce_mri_image_class.m 124 2012-12-11 23:43:40Z dgolden $

%% Setup
close all;

addpath(fullfile(danmatlabroot, 'parp'));

%% Load image
patient_id = 1;
str_pre_or_post_chemo = 'pre';
[slice_filename, roi_filename] = get_slice_filename(patient_id, str_pre_or_post_chemo);
slice = load(slice_filename);
roi = load(roi_filename);

PDMI = PARPDCEMRIImage(patient_id, str_pre_or_post_chemo, slice.slices, slice.info, slice.x_mm, slice.y_mm, slice.z_mm, slice.start_datenum, slice.t);

%% Plot empirical map without ROI
% PDMI = CreateEmpiricalMaps(PDMI);
% PlotEmpiricalMapHSV(PDMI);

%% Create ROI
PDMI = CreateEmpiricalMaps(PDMI);

% PDMI = CreateROI(PDMI);
[PDMI.ROIPolyX, PDMI.ROIPolyY] = mm_to_px(PDMI.XCoordmm, PDMI.YCoordmm, roi.roi_poly.img_x_mm, roi.roi_poly.img_y_mm);

%% Get PK Parameters
PDMI = CreatePKMaps(PDMI);

%% Plot maps with ROI
PlotEmpiricalMapHSV(PDMI, 'b_roi', true);
PlotMapOnPostImg(PDMI, 'IFKtrans', 'b_colorbar', false);

1;
