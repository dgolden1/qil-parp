function [dicom_filename, aim_filename] = ExportAIMDICOMPair(obj, output_dir, varargin)
% Create an AIM and DICOM pair, suitable for sharing an ROI or running through Jiajing's
% pipeline

% By Daniel Golden (dgolden1 at stanford dot edu) April 2013
% $Id: ExportAIMDICOMPair.m 347 2013-07-17 00:05:49Z dgolden $

%% Setup
addpath(fullfile(danmatlabroot, 'aim_from_dicom'));

%% Parse input arguments
p = inputParser;
p.addParamValue('SOPInstanceUID', generate_random_string(25));
p.addParamValue('SeriesInstanceUID', generate_random_string(25));
p.addParamValue('StudyInstanceUID', generate_random_string(25));
p.addParamValue('SOPClassUID', '1.2.840.10008.5.1.4.1.1.2'); % See http://www.apteryx.fr/dicom/dicom_conformance for more SOPClassUID options
p.addParamValue('b_is_ct', true); % Used to appropriately set DICOM RescaleIntercept
p.addParamValue('output_filename', patient_id_tostr(obj.PatientID)); % Should not have extension or path
p.addParamValue('b_verbose', true);
p.addParamValue('b_stop_on_aim_error', true);
p.parse(varargin{:});

[path, filename, ext] = fileparts(p.Results.output_filename);
if ~isempty(path)
  output_filename = fullfile(path, filename);
else
  output_filename = fullfile(output_dir, filename);
end
output_filename = expand_tilde(output_filename);

%% Create DICOM file
dicom_filename = [output_filename '.dcm'];

if p.Results.b_is_ct
  if min(obj.Image(:)) < -1000
    error('Min value of images (%0.0f) is lower than CT minimum (-1000)', min(obj.Image(:)));
  end
  
  img = uint16(obj.Image + 1024);
  rescale_intercept = -1024;
else
  img_range = diff(quantile(obj.Image(:), [0 1]));
  if img_range > intmax('uint16')
    error('Image range (%0.0f) exceeds maximum representable int16 value (%d)', img_range, intmax('uint16'));
  end
  
  min_val = min(obj.Image);
  img = uint16(obj.Image - min_val);
  rescale_intercept = uint16(min_val);
end

dicomwrite(img, dicom_filename, ...
           'SOPInstanceUID', p.Results.SOPInstanceUID, ...
           'SeriesInstanceUID', p.Results.SeriesInstanceUID, ...
           'StudyInstanceUID', p.Results.StudyInstanceUID, ...
           'SOPClassUID', p.Results.SOPClassUID, ...
           'RescaleIntercept', rescale_intercept, ...
           'PatientName', obj.PatientID, ...
           'PatientID', obj.PatientID);

if p.Results.b_verbose
  fprintf('Saved %s\n', dicom_filename);
end

%% Create AIM file
aim_filename = [output_filename '.xml'];
generate_aim_file_from_roi(obj.MyROI.ROIPolyX, obj.MyROI.ROIPolyY, aim_filename, dicom_filename, ...
  'b_verbose', p.Results.b_verbose, 'b_stop_on_aim_error', p.Results.b_stop_on_aim_error);


function str = generate_random_string(len)
%% Function: Generate a random string

% char_list = char([48:57, 97:122, 65:90]); % Upper and lowercase letters and numbers
char_list = char(48:57); % Upper and lowercase letters and numbers

str = repmat(' ', 1, len);
for kk = 1:len
  str(kk) = char_list(randi(length(char_list)));
end