function obj = CreateFromDICOMDB(dicom_db, varargin)
% Create from a DICOMDB object that has only one slice (and multiple time points)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('patient_id', 'xxx');
p.parse(varargin{:});

%% Confirm images are one slice with unique time points
if ~all(abs([dicom_db.DICOMList.SliceCoordmm] - dicom_db.DICOMList(1).SliceCoordmm) < 1)
  error('Images are not all in the same plane');
end
if ~isunique([dicom_db.DICOMList.Time])
  error('Time points are not unique');
end
if ~issorted([dicom_db.DICOMList.Time])
  error('Time points are not sorted');
end

%% Create image stack and DICOM info
dicom_image_1 = dicom_db.DICOMList(1).UpdateAllCoordinates;
image_stack = zeros(length(dicom_image_1.YCoordmm), length(dicom_image_1.XCoordmm), length(dicom_db.DICOMList));
for kk = 1:length(dicom_db.DICOMList)
  image_stack(:,:,kk) = dicom_db.DICOMList(kk).GetImage;
  image_dicom_info(kk) = dicom_db.DICOMList(kk).DICOMInfo;
  
  fprintf('Processed image %d of %d\n', kk, length(dicom_db.DICOMList));
end

%% Create DCEMRIImage
[x_mm, y_mm, z_mm, slice_plane] = get_dicom_xyz(image_dicom_info(1));
datenums = [dicom_db.DICOMList.Time];
start_datenum = min(datenums);
t = datenums - min(datenums);

obj = DCEMRIImage(p.Results.patient_id, '', image_stack, image_dicom_info, x_mm, y_mm, z_mm, start_datenum, t);
