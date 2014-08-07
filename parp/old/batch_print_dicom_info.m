function [patient_id, mm_per_pixel] = batch_print_dicom_info
% Print some info from the DICOM headers for each patient

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Setup
[~, patient_dirs] = get_processed_patient_list;

mm_per_pixel = [];
patient_id = [];
for kk = 1:length(patient_dirs)
  this_patient_dir = patient_dirs{kk};

  try
    [slice_filename, roi_filename, pk_filename] = get_slice_filename(this_patient_dir, false);
  catch er
    switch er.identifier
      case {'getSlice:multipleSlices', 'getSlice:noSlices'}
        fprintf('%s; skipping...\n', er.message);
        continue;
      otherwise
        rethrow(er);
    end
  end
  
  load(slice_filename, 'x_mm', 'y_mm', 'z_mm', 'info', 't');
  
  [x_coord_mm, y_coord_mm] = get_img_coords(x_mm, y_mm, z_mm);
  mm_per_pixel(end+1) = abs(median(diff(x_coord_mm)));
  patient_id(end+1) = get_patient_id_from_name(patient_dirs(kk).name);
  
  if isfield(info, 'InstitutionName')
    institution = info(1).InstitutionName;
  else
    institution = '';
  end

  fprintf('Patient %d (%s): %0.2f mm/pixel\n', patient_id(end), institution, mm_per_pixel(end));
  
  1;
end
