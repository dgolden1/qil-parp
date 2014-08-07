function batch_get_pk_params(str_pre_or_post_chemo)
% Get pharmacokinetic parameters for all lesions using Nick's code

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp', 'nicks_PK_code', 'DCE'));
addpath(fullfile(qilsoftwareroot, 'parp', 'nicks_PK_code', 'LS'));

%% Cycle through patients
patient_ids = get_processed_patient_list(str_pre_or_post_chemo);
b_overwrite = false;
b_skip_errors = false;

h_fig = figure;

for kk = 1:length(patient_ids)
  t_start = now;
  
  this_patient_id = patient_ids(kk);
  
  fprintf('Processing patient %03d (%d of %d)\n', this_patient_id, kk, length(patient_ids));
  
  try
    close all;
  
    get_pk_params_from_patient_id(this_patient_id, str_pre_or_post_chemo, b_overwrite, b_skip_errors, h_fig);
    fprintf('Processed patient %d in %s\n', this_patient_id, time_elapsed(t_start, now));

    this_output_filename = sprintf('pk_%03d_%s.png', this_patient_id, str_pre_or_post_chemo);
    output_pk_image_name = fullfile(parp_patient_dir, 'images_pk', str_pre_or_post_chemo, this_output_filename);
    print_trim_png(output_pk_image_name);
    fprintf('Wrote %s\n', output_pk_image_name);
  catch er
    if any(strcmp({'getPK:noROIs', 'getPK:multipleROIs', 'getPK:PKFileExists'}, er.identifier))
      fprintf('%s\n', er.message);
      continue;
    else
      rethrow(er);
    end
  end
end
