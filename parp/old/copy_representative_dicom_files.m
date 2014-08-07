function copy_representative_dicom_files
% Copy one dicom file for each patient to a common directory
% Use to populate lookup table for Wouter Veldhuis' DICOM Anonymizer program

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

%% Setup
source_dir = '/Users/dgolden/Documents/qil/parp_patient_data/dicom_anon/pre_incoming';
dest_dir = '/Users/dgolden/temp/representative_dicom_files';
if ~exist(dest_dir, 'dir')
  mkdir(dest_dir);
end

%% Get list of directories
d = dir(source_dir);
d = d([d.isdir]);
d = d(cellfun(@(x) x(1) ~= '.', {d.name})); % Get rid of dirs that start with .
%d = d(cellfun(@(x) length(x) <= 7, {d.name})); % Get rid of patients in format 004001 (non-Stanford patients)

%% Get a representative file for each
for kk = 1:length(d)
  cmd = sprintf('find %s -name "*.dcm" | head -n 1', fullfile(source_dir, d(kk).name));
  [~, dicom_full_filename] = system(cmd);
  dicom_full_filename = dicom_full_filename(1:end-1); % Remove newline
  dicom_filename = just_filename(dicom_full_filename);
  copyfile(dicom_full_filename, fullfile(dest_dir, sprintf('file_%03d_rep_img.dcm', kk)));
  fprintf('Copied %s to %s (%d of %d)\n', dicom_full_filename, dest_dir, kk, length(d));
end
