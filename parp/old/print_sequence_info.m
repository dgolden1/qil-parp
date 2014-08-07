function print_sequence_info
% Go through the downloaded patients and print some info about their MR
% sequences

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

str_pre_or_post = 'pre';

load('lesion_parameters.mat', 'lesions');
[~, sort_idx] = sort([lesions.patient_id]);
lesions = lesions(~is_stanford_scan([lesions.patient_id], str_pre_or_post));

for kk = 1:length(lesions)
  this_patient_id = lesions(kk).patient_id;
  ss_info = get_spreadsheet_info(this_patient_id);
  this_sequence_name = ss_info.dynamic_sequence;
  this_site_name = ss_info.pre_mri_location;
  
  slice_filename = get_slice_filename(this_patient_id);
  slice = load(slice_filename);
  
  dt = diff(slice.t);
  unique_dt = unique(diff(roundto(slice.t, 1)));
  
  fprintf('Patient %03d; Sequence %s; total t = %0.0f sec; dt = ', this_patient_id, this_sequence_name, median(dt(2:end))*length(dt));
  for jj = 1:length(dt)
    fprintf('%0.0f ', dt(jj));
  end
  fprintf('sec\n');
end
