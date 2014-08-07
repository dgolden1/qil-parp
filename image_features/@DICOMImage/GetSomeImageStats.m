function stats_struct = GetSomeImageStats(obj)
% Get some useful statistics about the images
% stats_struct = GetSomeImageStats(obj)

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Run
stats_struct.patient_id = obj.PatientID;
stats_struct.time = obj.Time;

%% Get information from the DICOM header, which may be missing fields
header_map = containers.Map('ValueType', 'char');
header_map('pixel_spacing') = 'PixelSpacing';
header_map('slice_thickness') = 'SliceThickness';
header_map('series_description') = 'SeriesDescription';
header_map('institution') = 'InstitutionName';
header_map('manufacturer') = 'Manufacturer';
header_map('manufacturer_model') = 'ManufacturerModel';
header_map('convolution_kernel') = 'ConvolutionKernel';

dicom_info = obj.DICOMInfo;

key_list = keys(header_map);
for kk = 1:length(key_list)
  this_key = key_list{kk};
  if isfield(dicom_info, header_map(this_key))
    val = dicom_info.(header_map(this_key));
    if strcmp(this_key, 'pixel_spacing')
      % Pixel spacing returns two numbers, but they're always the same
      assert(length(val) == 2 && val(1) == val(2));
      stats_struct.(this_key) = val(1);
    else
      stats_struct.(this_key) = val;
    end
  elseif ismember(this_key, {'pixel_spacing', 'slice_thickness'})
    stats_struct.(this_key) = nan;
  else
    stats_struct.(this_key) = 'N/A';
  end
end
