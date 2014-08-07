function test_glcm_levels
% See how different choices of the number of GLCM levels affect the
% returned parameter values

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

%% Setup
close all
output_filename = '~/temp/glcm_vs_num_levels.png';

numpatients = 10;

%% Get patient list and loop over patients
num_levels_vec = round(2.^(1:1:9));

patient_id = get_processed_patient_list('pre');
patient_id = patient_id(1:numpatients);

for kk = 1:length(patient_id)
  glcm_props(kk, :) = get_glcm_props_for_one_patient(patient_id(kk), num_levels_vec);
end

%% Plot
fn = fieldnames(glcm_props);

figure;
figure_grow(gcf, 2);

for kk = 1:length(fn)
  subplot(2, 2, kk);
  
  this_val = reshape([glcm_props.(fn{kk})], size(glcm_props, 1), size(glcm_props, 2));

  switch fn{kk}
    case {'Contrast', 'Energy'}
      loglog(num_levels_vec, this_val, '-s', 'markerfacecolor', 'w');
    otherwise
      semilogx(num_levels_vec, this_val, '-s', 'markerfacecolor', 'w');
  end
  
  ylabel(fn{kk});
  
  if kk > 2
    xlabel('Num GLCM Levels');
  end
  
  grid on;
end

increase_font;

print_trim_png(output_filename);
fprintf('Saved %s\n', output_filename);


function glcm_props = get_glcm_props_for_one_patient(patient_id, num_levels_vec)
%% Function: get GLCM props for one patient

%% Load image
[slice_filename, roi_filename, pk_filename] = get_slice_filename(patient_id, 'pre');
load(slice_filename);
load(roi_filename);
load(pk_filename);

img = nan(size(roi_mask));
img(roi_mask) = ktrans;

%% Calculate GLCM for different number of levels
for kk = 1:length(num_levels_vec)
  num_levels = num_levels_vec(kk);
  
  glcm_props(kk) = get_glcm_properties(img, [], [], num_levels);
end



1;
