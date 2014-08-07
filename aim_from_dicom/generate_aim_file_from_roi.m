function generate_aim_file_from_roi(x_roi, y_roi, output_filename, dicom_filename, varargin)
% Function to extract a DICOM file and generate an AIM file from a slice and ROI file
% generate_aim_file_from_roi(x_roi, y_roi, output_filename, dicom_filename, varargin)
% 
% Get AIM API from http://www.stanford.edu/group/qil/cgi-bin/mediawiki/index.php/AIM_API
% 
% INPUTS
% x_roi: x-coordinates of ROI (in IMAGE coordinates, i.e., pixels, NOT
%  DICOM coordinates)
% y_roi: y-coordinates of ROI
% output_filename: output filename for generated AIM file
% dicom_filename: DICOM file to reference for the generated AIM file; only
%  the header is examined for various UID stuff
% 
% PARAMETERS
% unique_identifier_str: a unique identifier string for the AIM file; if
%  not given, a random number is used
% path_to_aim_api: path to AIM api (should contain AIMv3API.jar)
% AIM_XSD_filename: path to file AIM_v3.xsd
% b_verbose: print some output (default: true)
% b_stop_on_aim_error: throw an error if the AIM write fails (default: true)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('unique_identifier_str', num2str(randi(1e8), '%08d'));
p.addParamValue('path_to_aim_api', '');
p.addParamValue('AIM_XSD_filename', '');
p.addParamValue('b_verbose', true);
p.addParamValue('b_stop_on_aim_error', true);
p.parse(varargin{:});

unique_identifier_str = p.Results.unique_identifier_str;

if ~isempty(p.Results.path_to_aim_api)
  path_to_aim_api = p.Results.path_to_aim_api;
elseif exist('danmatlabroot', 'file') && isempty(p.Results.path_to_aim_api)
  path_to_aim_api = fullfile(qilsoftwareroot, 'aim_api');
elseif isempty(p.Results.path_to_aim_api)
  error('Must specify option path_to_aim_api');
end
if ~isempty(p.Results.AIM_XSD_filename)
  AIM_XSD_filename = p.Results.AIM_XSD_filename;
elseif exist('danmatlabroot', 'file') && isempty(p.Results.AIM_XSD_filename)
  AIM_XSD_filename = fullfile(qilsoftwareroot, 'aim_from_dicom', 'AIM_v3.xsd');
elseif isempty(p.Results.AIM_XSD_filename)
  error('Must specify option AIM_XSD_filename');
end

%% Setup
output_filename = expand_tilde(output_filename);

%% Import AIM API
% Add AIM API to Java path
add_aim_api_to_path(path_to_aim_api);

import edu.stanford.hakan.aim3api.base.*; 
import edu.stanford.hakan.aim3api.usage.*;
import java.util.*;
import java.io.*;

if ~exist('ImageAnnotation', 'class')
  error('Unable to call AIM API; verify path is accurate, then run ''clear java'' on command prompt and try again');
end

%% A bunch of constants
cagridId = java.lang.Integer(0);

%% Load slice and set up AIM attributes
% Formerly, got info from slice; instead get info from DICOM file that is
% associated with this AIM file
info = dicominfo(dicom_filename);
% load(slice_filename);

annotation_date_str = datestr(now, 'yyyy-mm-ddTHH:MM:SS');
imageSopInstanceUID = info(1).SOPInstanceUID;
imageStudyInstanceUID = info(1).StudyInstanceUID;
imageSeriesInstanceUID = info(1).SeriesInstanceUID;
imageSopClassUID = info(1).SOPClassUID;

% I don't know what most of this stuff is; I copied it from Katie Planey's
% code --DIG 2012-07-18
[~, dicom_filename_noext] = fileparts(dicom_filename);

% For some reason probably relating to importing the java stuff, this function
% always seems to fail with a MATLAB:UndefinedFunction error the first time I try to
% run it, but it succeeds on subsequent attempts
image_annotation_java = ImageAnnotation(cagridId,'AIM.1.0','',annotation_date_str, dicom_filename_noext, ...
  unique_identifier_str, '112041','Breast MR', 'DCM', '', '');

% Set up person
person_java = Person;
person_java.setCagridId(cagridId);

if isfield(info, 'PatientName')
  if isfield(info(1).PatientName, 'FamilyName')
    person_java.setName(info(1).PatientName.FamilyName);
  elseif ischar(info(1).PatientName)
    person_java.setName(info(1).PatientName);
  end
end
if isfield(info, 'PatientID')
  person_java.setId(info(1).PatientID);
end
if isfield(info, 'PatientSex')
  person_java.setSex(info(1).PatientSex);
end

image_annotation_java.addPerson(person_java);

%% Create ROI
poly_java = Polyline(cagridId,'','','','',jbool(false),jint(-1));
referenced_frame_num = jint(0);
for kk = 1:length(x_roi)
  this_coord_java = TwoDimensionSpatialCoordinate(cagridId, jint(kk-1), imageSopInstanceUID, ...
    referenced_frame_num, jdouble(x_roi(kk)), jdouble(y_roi(kk)));
  poly_java.addSpatialCoordinate(this_coord_java);
end

image_annotation_java.addGeometricShape(poly_java);

%% Create DICOM Image Reference
image_study_java = ImageStudy;
image_study_java.setCagridId(cagridId);
image_study_java.setInstanceUID(imageStudyInstanceUID);
image_study_java.setStartDate(annotation_date_str);
image_study_java.setStartTime('+00:00:00.000000');

image_series_java = ImageSeries;
image_series_java.setCagridId(cagridId);
image_series_java.setInstanceUID(imageSeriesInstanceUID);

image_java = Image;
image_java.setCagridId(cagridId);
image_java.setSopClassUID(imageSopClassUID);
image_java.setSopInstanceUID(imageSopInstanceUID);

% Add image to image series
image_series_java.addImage(image_java);

% Add image series to study
image_study_java.setImageSeries(image_series_java);

% Add image study to DICOM reference
dicom_img_ref_java = DICOMImageReference;
dicom_img_ref_java.setImageStudy(image_study_java);
dicom_img_ref_java.setCagridId(cagridId);

% Add DICOM image reference to this annotation
image_annotation_java.addImageReference(dicom_img_ref_java);

%% Save
AnnotationBuilder.saveToFile(image_annotation_java, output_filename, AIM_XSD_filename);
result_str = AnnotationBuilder.getAimXMLsaveResult();

if strcmp(char(result_str), 'XML Saving operation is Successful.')
  if p.Results.b_verbose
    fprintf('Saved %s\n', output_filename);
  end
else
  aim_error = sprintf('Error saving %s: %s', output_filename, char(result_str));
  if p.Results.b_stop_on_aim_error
    error(aim_error);
  else
    fprintf('%s\n', aim_error);
  end
end

1;


function java_string = jstr(matlab_string)
%% Function: convert Matlab string to Java string
java_string = java.lang.String(matlab_string);

function java_integer = jint(val)
%% Function: convert Matlab number to Java integer
java_integer = java.lang.Integer(val);

function java_double = jdouble(val)
%% Function: convert Matlab number to Java double
java_double = java.lang.Double(val);

function java_boolean = jbool(val)
%% Function: convert Matlab boolean to Java boolean
java_boolean = java.lang.Boolean(val);
