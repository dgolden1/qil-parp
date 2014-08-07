function obj = CreateEmpiricalMaps(obj)
% Create empirical maps

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup

%% Choose time points
[t1, t2, t3, b_high_t_res] = GetEmpiricalTimePoints(obj);

%% Get 3 time-point values
% Convert image stack into KxR matrix of R pixels at K time points
% Indexed as:  slices_vec(time_idx, pixel_idx)
slices_vec = reshape(obj.ImageStack, prod(obj.Size2D), size(obj.ImageStack, 3)).';

% If inter-slice spacing is very low (< 30 seconds), we'll average a few slices at each
% of the three time points; otherwise, we'll choose a single time point (or an
% interpolation between two time points)
if b_high_t_res
  t1_idx = obj.Time <= t1;
  t2_idx = abs(obj.Time - t2) <= 30; % Within 30 sec radius of t2
  t3_idx = obj.Time >= t3 - 60; % Within 60 seconds before t3
  if ~any(t1_idx) || ~any(t2_idx) || ~any(t3_idx)
    error('t1, t2 or t3 ranges are missing time points');
  end
  
  ampl1 = mean(slices_vec(t1_idx, :), 1);
  ampl2 = mean(slices_vec(t2_idx, :), 1);
  ampl3 = mean(slices_vec(t3_idx, :), 1);
else
  empirical_ampl = interp1(obj.Time, slices_vec, [t1 t2 t3]).';
  ampl1 = empirical_ampl(:,1); % Initial amplitude
  ampl2 = empirical_ampl(:,2); % Amplitude after wash-in
  ampl3 = empirical_ampl(:,3); % Final amplitude
end

wash_in_slope = (ampl2 - ampl1)/(t2 - t1)*60; % Contrast units/min
wash_out_slope = (ampl3 - ampl2)/(t3 - t2)*60; % Contrast units/min

%% Get AUC and post-contrast image

% This is really the mean, not the area, but the mean is better for normalization when
% different sequences can have more or fewer time points than others
area_under_curve = mean(slices_vec(obj.Time >= t1 & obj.Time <= t3, :), 1);

if all(~isfinite(area_under_curve))
  warning('area under curve is 0');
end

% Just the post-contrast image (at time 2)
post_contrast_img = ampl2;

%% Set object ImageFeature properties
images = {reshape(wash_in_slope, obj.Size2D), ...
          reshape(wash_out_slope, obj.Size2D), ...
          reshape(area_under_curve, obj.Size2D), ...
          reshape(post_contrast_img, obj.Size2D)};
image_names = {'wash_in', 'wash_out', 'AUC', 'post_contrast'};
image_pretty_names = {'Wash-In', 'Wash-Out', 'Area Under Contrast Curve', 'Post-Contrast'};
object_property_names = {'IFWashIn', 'IFWashOut', 'IFAUC', 'IFPostContrast'};

for kk = 1:length(images)
  obj.(object_property_names{kk}) = ImageFeature(images{kk}, image_names{kk}, obj.PatientID, ...
    'ImagePrettyName', image_pretty_names{kk}, 'SpatialXCoords', obj.XCoordmm, 'SpatialYCoords', obj.YCoordmm, ...
    'SpatialCoordUnits', 'mm');
  
  obj.(object_property_names{kk}).MyROI = obj.MyROI;
end
