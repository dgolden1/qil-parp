function patient_dir = get_patient_dir_from_id(patient_id, str_pre_or_post_chemo, b_create_if_no_exist)
% Determine patient directory from patient id
%
% str_pre_or_post_chemo can be either 'pre' or 'post'
% 
% If more than one patient_id is given, patient_dir is a cell array of
% string; otherwise, it is a string

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$
%% Setup
if ~exist('b_create_if_no_exist', 'var') || isempty(b_create_if_no_exist)
  b_create_if_no_exist = false;
end

%% Assemble directory name for each patient ID
for kk = 1:length(patient_id)
  patient_dir{kk} = fullfile(parp_patient_dir, 'matlab', upper(str_pre_or_post_chemo), sprintf('%03d%s', patient_id, upper(str_pre_or_post_chemo)));
  if ~exist(patient_dir{kk}, 'dir')
    if ~b_create_if_no_exist
      error('Directory %s does not exist', patient_dir{kk});
    else
      mkdir(patient_dir{kk});
      fprintf('Created %s\n', patient_dir{kk});
    end
  end
end

%% Return a string if patient_id is scalar, a cell array of string otherwise
if length(patient_dir) == 1
  patient_dir = patient_dir{1};
end
