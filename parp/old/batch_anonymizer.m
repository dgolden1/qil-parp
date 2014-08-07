function batch_anonymizer(patient_dir)
% Anonymize some select patient data

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
if ~exist('patient_dir', 'var') || isempty(patient_dir)
  patient_dir = '/Users/dgolden/Documents/qil/parp_patient_data/dicom_anon/POST';
  b_provided_dir = false;
else
  b_provided_dir = true;
end

% If user provided the directory, loop over subdirectories and run unix
% find command; otherwise, just run find on the user-provided directory
if b_provided_dir
  patient_dirs = {patient_dir};
else
  d = dir(patient_dir);
  idx_valid = [d.isdir] & cellfun(@(x) x(1) ~= '.', {d.name});
  d = d(idx_valid);

  patient_dirs = cellfun(@(x) fullfile(patient_dir, x), {d.name}, 'UniformOutput', false);
end

%% Loop
for kk = 1:length(patient_dirs)
  this_patient_dir = patient_dirs{kk};
  patient_name = regexp(this_patient_dir, '\d{3}(PRE|POST)', 'match');
  this_patient_id = get_patient_id_from_name(just_filename(patient_name));
  assert(isfinite(this_patient_id));
  
  cmd = sprintf('find "%s" -name "*.dcm"', this_patient_dir);
  [~, dcm_str] = system(cmd);
  C = textscan(dcm_str, '%[^\n]');
  dicom_filenames = C{1};
  
  for jj = 1:length(dicom_filenames);
    t_file_start = now;
    
    % Don't write output file unless file metadata is changed
    b_file_changed = false;
    
    this_filename = dicom_filenames{jj};
    X = dicomread(this_filename);
    X_info = dicominfo(this_filename);
    if ismember(X_info.BitDepth, [12 16])
      int_class = @int16;
    elseif ismember(X_info.BitDepth, 8)
      int_class = @uint8;
    else
      error('BitDepth = %0.0f', X_info.BitDepth);
    end
    
    % Anonymize
    
    % Replace patient ID with PARP subject ID
    new_patient_id = sprintf('%03d', this_patient_id);
    if ~strcmp(X_info.PatientID, new_patient_id)
      X_info.PatientID = sprintf('%03d', this_patient_id);
      b_file_changed = true;
    end
    
    % Remove some fields with identifying info
    fields_with_phi = {'OtherPatientID', 'OtherPatientIDs', 'OtherPatientName', 'OtherPatientNames'};
    
    % Remove some fields that generate errors when saving
    fields_with_errors = {'IconImageSequence', 'OriginalAttributesSequence'};
    fields_to_remove = [fields_with_phi fields_with_errors];
    for ii = 1:length(fields_to_remove)
      if isfield(X_info, fields_to_remove{ii})
        X_info = rmfield(X_info, fields_to_remove{ii});
        b_file_changed = true;
      end
    end
    
    % Write
    if b_file_changed
      dicomwrite(uint16(X), this_filename, X_info, 'CreateMode', 'Copy');
      fprintf('Wrote %s (%d of %d for patient %d) in %s\n', this_filename, jj, length(dicom_filenames), this_patient_id, time_elapsed(t_file_start, now));
    else
      fprintf('Skipped %s (%d of %d for patient %d); was already anonymized\n', this_filename, jj, length(dicom_filenames), this_patient_id);
    end
  end
end
