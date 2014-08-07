function obj = CreateDBFromExistingFiles(str_pre_or_post_chemo, varargin)
% Create the database from existing slice files

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Setup
t_net_start = now;

if ~exist('str_pre_or_post_chemo', 'var') || isempty(str_pre_or_post_chemo)
  error('Must specify pre or post chemo');
end

b_parallel = true;
if b_parallel && matlabpool('size') == 0
  matlabpool('open');
end

%% Parse input args
p = inputParser;
p.addParamValue('b_overwrite_existing', false);
p.addParamValue('common_pixel_size', []);
p.parse(varargin{:});

%% Get patient list
patient_ids = get_processed_patient_list(str_pre_or_post_chemo);

% Remove excluded patients
excluded_ids = get_excluded_patient_list;
patient_ids = patient_ids(~ismember(patient_ids, excluded_ids));

%% Create database

if isempty(p.Results.common_pixel_size)
  obj = PARPDB(str_pre_or_post_chemo);
else
  obj = PARPDB(str_pre_or_post_chemo, p.Results.common_pixel_size);
end

if ~p.Results.b_overwrite_existing
  % Only process patients which aren't already in the database
  existing_patient_ids = GetPatientList(obj);
  patient_ids = patient_ids(~ismember(patient_ids, existing_patient_ids));
end

% patient_ids = patient_ids(1:3); % For debugging

% Loop over patients and create PARPDCEMRIImage objects in parallel
image_list = PARPDCEMRIImage.empty;
progress_temp_dirname = parfor_progress_init;
for kk = 1:length(patient_ids)
  t_start = now;

  PDMI = PARPDCEMRIImage.CreateFromExistingOldStyle(patient_ids(kk), str_pre_or_post_chemo);
  if ~isempty(p.Results.common_pixel_size)
    if PDMI.PixelSpacing > p.Results.common_pixel_size
      % Don't decrease the pixel size (increase the resolution) of any images
      warning('Pixel size for patient %03d (%0.2f) is larger than common pixel size (%0.2f); skipping...', ...
        PDMI.PatientID, PDMI.PixelSpacing, p.Results.common_pixel_size);
      continue;
    end
    
    PDMI = ResizeImage(PDMI, 'new_pixel_spacing', p.Results.common_pixel_size);
  end
  AddToDB(obj, PDMI);
  
  iteration_number = parfor_progress_step(progress_temp_dirname, kk);
  fprintf('Processed patient %03d (%d of %d) in %s\n', patient_ids(kk), iteration_number, length(patient_ids), time_elapsed(t_start, now));
end
parfor_progress_cleanup(progress_temp_dirname);


fprintf('Created database in %s\n', time_elapsed(t_net_start, now));
