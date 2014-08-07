function batch_save_aim_file_and_img(img_type_vec)
% Run save_aim_file_and_img on all the images

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp'));

if ~exist('img_type_vec', 'var') || isempty(img_type_vec)
  % img_type_vec = {'post_img'};
  % img_type_vec = {'ktrans', 'kep', 've'};
  img_type_vec = {'wash_in', 'wash_out', 'auc'};
end

%% Run
patient_ids = get_processed_patient_list;

for kk = 1:length(patient_ids)
  for jj = 1:length(img_type_vec)
    t_start = now;
    idx = sub2ind([length(img_type_vec) length(patient_ids)], jj, kk);
    
    [dicom_filename, aim_filename] = save_aim_file_and_img(patient_ids(kk), img_type_vec{jj});
    fprintf('Processed %d of %d in %s\n', idx, length(patient_ids)*length(img_type_vec), time_elapsed(t_start, now));
  end
end
