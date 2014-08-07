function batch_make_glcm_struct(str_pre_or_post_chemo)
% Gather GLCM parameters into a struct and save it
% batch_make_glcm_struct(str_pre_or_post_chemo)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
t_net_start = now;

parameters_output_filename = fullfile(qilsoftwareroot, 'parp', sprintf('lesion_parameters_%s.mat', str_pre_or_post_chemo));

%% Loop over patients to get images, ROIs and PK parameters
patient_ids = get_processed_patient_list(str_pre_or_post_chemo);

t_net_start = now;
for kk = 1:length(patient_ids)
  t_patient_start = now;
  
  this_patient_id = patient_ids(kk);
  
  try
    [slice_filename, roi_filename, pk_filename] = get_slice_filename(this_patient_id, str_pre_or_post_chemo);
  catch er
    switch er.identifier
      case {'getSlice:multipleSlices', 'getSlice:noSlices'}
        fprintf('%s; skipping...\n', er.message);
        continue;
      otherwise
        rethrow(er);
    end
  end
  
  if isempty(roi_filename) || isempty(pk_filename)
    fprintf('Did not find exactly one ROI and PK file; skipping...\n');
    continue;
  end
  
  % Load lesion info
  load(slice_filename, 'slices', 'x_mm', 'y_mm', 'z_mm', 't', 'info');
  load(roi_filename, 'roi_mask', 'roi_poly');
  load(pk_filename, 'ktrans', 'kep', 've', 'b_known_contrast_protocol');
  
  % lesion.b_known_contrast_protocol = b_known_contrast_protocol;
  
  % Some slice processing
  slices_masked = reshape(slices(repmat(roi_mask, [1 1 length(t)])), [sum(roi_mask(:)), length(t)]);
  [x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);
  
  % Empirical parameters
  [wash_in_slope, wash_out_slope, area_under_curve, post_contrast_img] = get_empirical_params(slices_masked, info, t);
  
  % Get misc parameters
  lesion.patient_id = get_patient_id_from_name(info(1).PatientName.FamilyName);
  lesion.lesion_area = sum(roi_mask(:))*abs(median(diff(x_coord_mm))*median(diff(y_coord_mm))); % mm^2
  
  % RCB from spreadsheet
  spreadsheet_info = get_spreadsheet_info(lesion.patient_id);
  lesion.rcb_val = spreadsheet_info.rcb_value;

  % Lesion-averaged kinetic parameters
  [lesion.avg_ktrans, lesion.avg_kep, lesion.avg_ve, lesion.avg_wash_in, lesion.avg_wash_out, lesion.avg_auc] = ...
    get_lesion_average_pk(ktrans, kep, ve, wash_in_slope, wash_out_slope, area_under_curve);

  % Heterogeneity texture analysis via gray-level co-occurrence matrices
  glcm_stats = get_lesion_glcm_properties(x_mm, y_mm, z_mm, roi_mask, roi_poly, ...
    {ktrans, kep, ve, wash_in_slope, wash_out_slope, area_under_curve}, ...
    {'ktrans', 'kep', 've', 'wash_in_slope', 'wash_out_slope', 'auc'});
  
  % Each GLCM feature is its own field of the glcm_struct struct
  fn = fieldnames(glcm_stats);
  for jj = 1:length(fn)
    lesion.(sprintf('glcm_%s', fn{jj})) = glcm_stats.(fn{jj});
  end
  
  % Heterogeneity analysis via Rohan's segmentation code
  % lesion.num_regions = get_num_segmented_regions(x_mm, y_mm, z_mm, slices, roi_mask, ktrans, kep);
  
  % Add to glcm_struct struct
  if ~exist('glcm_struct', 'var')
    glcm_struct = lesion;
  else
    glcm_struct(end+1) = lesion;
  end
  
  fprintf('Processed patient %03d (%d of %d) in %s\n', lesion.patient_id, kk, length(patient_ids), time_elapsed(t_patient_start, now));
end
fprintf('Processed %d patients in %s\n', length(glcm_struct), time_elapsed(t_net_start, now));

save(parameters_output_filename, 'glcm_struct');
fprintf('Saved %s in %s\n', parameters_output_filename, time_elapsed(t_net_start, now));

1;

function brca_val = parse_brca(brca_str)
%% Function: assign brca value based on string

switch brca_str
  case 'Positive'
    brca_val = true;
  case {'Negative', 'VUS'}
    brca_val = false;
  otherwise
    brca_val = nan;
end

function [avg_ktrans, avg_kep, avg_ve, avg_wash_in, avg_wash_out, avg_auc] = get_lesion_average_pk(ktrans, kep, ve, wash_in, wash_out, auc)
%% Function: Lesion-averaged PK parameters

avg_ktrans = nanmean(ktrans);
avg_kep = nanmean(kep);
avg_ve = nanmean(ve);
avg_wash_in = nanmean(wash_in);
avg_wash_out = nanmean(wash_out);
avg_auc = nanmean(auc);

function num_regions = get_num_segmented_regions(x_mm, y_mm, z_mm, slices, roi_mask, ktrans, kep)
%% Function: get number of regions using Rohan's code

addpath(fullfile(qilsoftwareroot, 'parp', 'rohans_segmentation_code'));
addpath(fullfile(qilsoftwareroot, 'parp', 'rohans_segmentation_code', 'Additional_Functions'));
addpath(fullfile(qilsoftwareroot, 'parp', 'rohans_segmentation_code', 'Cluster_Verification'));

[x_coord_mm, y_coord_mm, x_label, y_label] = get_img_coords(x_mm, y_mm, z_mm);

% Crop out just the ROI
i_mask = any(roi_mask,2);
j_mask = any(roi_mask,1);

% Pad by one pixel so area outside region is contiguous (for segmentation)
i_mask([find(i_mask, 1, 'first') - 1, find(i_mask, 1, 'last') + 1]) = true;
j_mask([find(j_mask, 1, 'first') - 1, find(j_mask, 1, 'last') + 1]) = true;

slices_cropped = reshape(slices(i_mask, j_mask, :), [sum(i_mask) sum(j_mask) size(slices, 3)]);
x_coord_mm_cropped = x_coord_mm(j_mask);
y_coord_mm_cropped = y_coord_mm(i_mask);
roi_mask_cropped = interpn(1:size(slices, 1), 1:size(slices, 2), roi_mask, find(i_mask), find(j_mask), 'nearest');

% Cropped PK images
im_ktrans = nan(size(slices_cropped(:,:,1)));
im_ktrans(roi_mask_cropped) = ktrans;
im_kep = nan(size(slices_cropped(:,:,1)));
im_kep(roi_mask_cropped) = kep;
im_T10 = nan(size(slices_cropped(:,:,1)));
im_T10(roi_mask_cropped) = 1;

region_map = repmat(struct('Ktrans', nan, 'kep', nan, 'T10', nan), size(im_ktrans));
for kk = 1:size(im_ktrans, 1)
  for jj = 1:size(im_ktrans, 2)
    if any(isnan([im_ktrans(kk, jj) im_kep(kk, jj) im_T10(kk, jj)]))
      region_map(kk, jj).Ktrans = 0;
      region_map(kk, jj).kep = 0;
      region_map(kk, jj).T10 = 0;
    else
      region_map(kk, jj).Ktrans = im_ktrans(kk, jj);
      region_map(kk, jj).kep = im_kep(kk, jj);
      region_map(kk, jj).T10 = im_T10(kk, jj);
    end
  end
end
data_type = 'params';
nClusters_low = 4;
nClusters_high = 9;

output_map = Process_region_map(region_map, data_type, nClusters_low, nClusters_high);

num_regions = length(unique(output_map(:)));
