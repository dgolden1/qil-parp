function dicom_rt_roi_to_aim(dicom_rt_filename, roi_names_desired, dicom_dir, output_dir, varargin)
% Convert an ROI from a dicom_rt file to an AIM file
% dicom_rt_roi_to_aim(dicom_rt_filename, roi_names_desired, dicom_dir, output_dir, varargin)
% 
% INPUTS
% dicom_rt_filename: The DICOM-RT filename
% roi_names_desired: the name of the desired ROI in the DICOM-RT file; leave blank to
%  list names 
% dicom_dir: directory of original DICOM files
% output_dir: directory in which to save the AIM XML files
% 
% PARAMETERS
% dicom_db: enter an existing DICOMDB object to avoid creating it
% path_to_aim_api: path to AIM api (should contain AIMv3API.jar)
% AIM_XSD_filename: path to file AIM_v3.xsd
% 
% OUTPUTS
% none

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id$

%% Parse input args
p = inputParser;
p.addParamValue('dicom_db', []);
p.addParamValue('path_to_aim_api', '');
p.addParamValue('AIM_XSD_filename', '');
p.parse(varargin{:});

% [args_in, args_out] = arg_subset(varargin{:}, {});

if iscellstr(roi_names_desired) && length(roi_names_desired) > 1
  error('Must specify no more than one ROI name in roi_names_desired');
end

%% Create DICOMDB object
if isempty(p.Results.dicom_db)
  dicom_db = CreateFullDatabase(DICOMDB, dicom_dir, '');
else
  dicom_db = p.Results.dicom_db;
end

%% Get 3D ROI from DICOMRT object
if isempty(roi_names_desired)
  get_roi_from_dicomrt(dicom_rt_filename, {}, 'b_list_rois', true, 'dicom_db', dicom_db);
  return;
else
  roi_struct = get_roi_from_dicomrt(dicom_rt_filename, roi_names_desired, 'dicom_db', dicom_db);
end

%% Convert 3D ROI into a series of 2D ROIs and create AIM files
zvals = roi_struct.roi3d.ROIZValues;

for kk = 1:length(zvals)
  roi2d(kk) = GetROI2DAtZ(roi_struct.roi3d, zvals(kk), 'px');
  
  uid = roi_struct.uid{kk};
  dicom_image = dicom_db.DICOMList(dicom_db.MapUID(uid));
  
  output_filename = fullfile(output_dir, sprintf('%s_%03d_aim_roi.xml', roi_struct.name, zvals(kk)));

  generate_aim_file_from_roi(roi2d(kk).ROIPolyX, roi2d(kk).ROIPolyY, output_filename, dicom_image.Filename, ...
    'path_to_aim_api', p.Results.path_to_aim_api, 'AIM_XSD_filename', p.Results.AIM_XSD_filename);
  fprintf('Processed file %d of %d (UID: %s)\n', kk, length(zvals), uid);
end

1;
