function test_pk_model
% A function to test using Nick's pharmacokinetic modeling code on some
% data

% By Daniel Golden (dgolden1 at stanford dot edu) August 10, 2011 (Milo's
% Birthday)
% $Id$

%% Setup
close all;

[~,hostname] = system('hostname');
switch hostname(1:end-1)
  case 'quadcoredan.stanford.edu'
    dicom_dir = '/home/dgolden/temp/DCE_Tool';
  case 'dantop'
    dicom_dir = 'C:\Users\Daniel\temp\test_images';
end
d = dir(fullfile(dicom_dir, '*.dcm'));

%% Load dicom data
for kk = 1:length(d)
  info(kk) = dicominfo(fullfile(dicom_dir, d(kk).name));
  im_stack(:,:,kk) = dicomread(fullfile(dicom_dir, d(kk).name));
end

slice_locations = unique([info.SliceLocation]); % slice_idx location in Z axis (cm?)
trigger_times = unique([info.TriggerTime]); % Time of this image from first image (ms)

assert(size(im_stack, 3) == length(slice_locations)*length(trigger_times));

%% Show final slice minus first slice to see enhancement
slice_idx = 2;

figure;
h = imagesc(im_stack(:,:,[info.SliceLocation] == slice_locations(slice_idx) & ...
                         [info.TriggerTime] == max(trigger_times)) - ...
            im_stack(:,:,[info.SliceLocation] == slice_locations(slice_idx) & ...
                         [info.TriggerTime] == min(trigger_times)));
axis off tight;
colormap(gray);
caxis([0 quantile(double(flatten(im_stack)), 0.99)]);
colorbar;

%% Choose a voxel
x = 87;
y = 141;

%% Get information needed for Nick's code
time_vec = trigger_times/1e3/60; % Convert from ms to min
enhancement_data = squeeze(im_stack(x, y, [info.SliceLocation] == slice_locations(slice_idx)));
AIF_onset_time = 1; % I have no idea; this is a guess (min)
