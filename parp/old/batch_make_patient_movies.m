function batch_make_patient_movies(str_pre_or_post_chemo)
% Make movies for all processed patients showing contrast vs time

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
output_dir = fullfile(qilcasestudyroot, 'parp', 'registration_movies', str_pre_or_post_chemo);
if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% Loop over patients
[patient_ids, ~] = get_processed_patient_list(str_pre_or_post_chemo);
si = get_spreadsheet_info(patient_ids);

h_fig = figure;
figure_grow(gcf, 1, 1.75);
for kk = 1:length(patient_ids)
% for kk = find(patient_ids == 46)
  clf;
  
  this_patient_id = patient_ids(kk);
  [slice_filename, roi_filename] = get_slice_filename(this_patient_id, str_pre_or_post_chemo);
  sf = load(slice_filename);
  if ~isempty(roi_filename)
    roif = load(roi_filename);
  end
  
  try
    lesion_center_mm = get_lesion_center_from_spreadsheet(this_patient_id, str_pre_or_post_chemo);
  catch er
    if strcmp(er.identifier, 'LesionCenter:NoSlicePlane')
      lesion_center_mm = [];
    else
      rethrow(er);
    end
  end
  
  if isfield(sf, 'slices_unregistered')
    slices = {sf.slices_unregistered, sf.slices};
  else
    slices = {sf.slices, zeros(size(sf.slices))};
  end

  [x_coord_mm, y_coord_mm] = get_img_coords(sf.x_mm, sf.y_mm, sf.z_mm);
  output_filename = fullfile(output_dir, sprintf('%03d_%s_movie.avi', this_patient_id, str_pre_or_post_chemo));
  fig_title_prefix = sprintf('PARP\nPatient %d', this_patient_id);
  
  if isempty(roi_filename)
    make_slice_movie(slices, sf.t, x_coord_mm, y_coord_mm, output_filename, fig_title_prefix, 'h_fig', h_fig, 'lesion_center_mm', lesion_center_mm)
  else
    make_slice_movie(slices, sf.t, x_coord_mm, y_coord_mm, output_filename, fig_title_prefix, 'h_fig', h_fig, 'roi_mask', roif.roi_mask, 'roi_poly', roif.roi_poly, 'lesion_center_mm', lesion_center_mm)
  end
end
