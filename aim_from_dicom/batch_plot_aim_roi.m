function batch_plot_aim_roi
% Plot AIM ROIs for the files that I'm sending to Jiajing's feature
% pipeline

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Setup
input_dir = '/Users/dgolden/Documents/qil/case_studies/dicom_aim_for_jiajing_pipeline/dicom_aim_post_img';
output_dir = '/Users/dgolden/temp/aim_rois';

if ~exist(output_dir, 'dir')
  mkdir(output_dir);
end

%% List input files
d_xml = dir(fullfile(input_dir, '*.xml'));
d_dcm = dir(fullfile(input_dir, '*.dcm'));
assert(length(d_xml) == length(d_dcm));

%% Plot and save
figure;
figure_grow(gcf, 1.7, 1);

for kk = 1:length(d_xml)
  % Ensure that the patient numbers are the same for the XML and DICOM
  % files
  assert(str2double(d_xml(kk).name(1:3)) == str2double(d_dcm(kk).name(1:3)));
  patient_name = d_xml(kk).name(1:6); % Name(1:6) should be in form 001PRE
  
  plot_aim_roi(fullfile(input_dir, d_dcm(kk).name), fullfile(input_dir, d_xml(kk).name), gcf);
  title(patient_name);
  increase_font;

  output_filename = fullfile(output_dir, sprintf('%s_ROI', patient_name));
  print_trim_png(output_filename);
end

