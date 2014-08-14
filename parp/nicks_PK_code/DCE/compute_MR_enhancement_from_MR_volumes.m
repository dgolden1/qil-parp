function enhancement_matrix = compute_MR_enhancement_from_MR_volumes(DCE_MRI_Struct, voxel_idx, varargin)

% Function originally by Nick Hughes (nhughes at stanford dot edu)
% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

enhancement_matrix = [];
sample_times = DCE_MRI_Struct.sample_times;

if length(varargin) > 0
  AIF_onset_time = varargin{1};
else
  AIF_onset_time = sample_times(2);
  fprintf('No AIF onset time passed to %s: assuming injection occurs at the second time sample (%1.2f)\n', mfilename, AIF_onset_time);
end

if isempty(AIF_onset_time)
  error('%s: AIF onset time variable is empty...', mfilename);
end

if length(AIF_onset_time) > 1
  error('%s: AIF onset time variables is a vector, should be a scalar...', mfilename);
end

% Check that the AIF onset time is valid
if sample_times(end) < AIF_onset_time
  error('AIF onset time (%1.2f) occurs after the last time point (%1.2f)', AIF_onset_time, sample_times(end));
end

if sample_times(1) >= AIF_onset_time
  error('AIF onset time (%1.2f) occurs on or before the first time point (%1.2f)', AIF_onset_time, sample_times(1));
end

% Compute the number of pre-injection volumes
num_pre_injection_volumes = length(find(sample_times < AIF_onset_time));

if num_pre_injection_volumes == 0
  error('No time points occur before the AIF onset time (%1.2f)', AIF_onset_time);
end

% Compute the mean MRI volume over the pre_injection scans
sum_pre_injection_volumes = zeros(size(DCE_MRI_Struct.Data{1}));

for v=1:num_pre_injection_volumes
  sum_pre_injection_volumes = sum_pre_injection_volumes + DCE_MRI_Struct.Data{v};
end

mean_pre_injection_volume = sum_pre_injection_volumes / num_pre_injection_volumes;

% Set any zeros values to one so that we don't get divide by zero
% warnings when computing the relative enhancement
is_zero_idx = find(mean_pre_injection_volume==0);  
mean_pre_injection_volume(is_zero_idx) = 1;

% Setup enhancement matrix
num_volumes = length(DCE_MRI_Struct.Data);
enhancement_matrix = zeros(length(voxel_idx), num_volumes);

% Compute enhancement values
for v=1:num_volumes
  % Compute the enhancement for this volume
  enhancement_vol = (DCE_MRI_Struct.Data{v}./mean_pre_injection_volume) - 1;

  % Set the enhancement to zero for any voxels where the pre_injection MR value was zero
  enhancement_vol(is_zero_idx) = 0;
  
  % Store the required voxels in the enhancement matrix
  enhancement_matrix(:,v) = enhancement_vol(voxel_idx);
end
