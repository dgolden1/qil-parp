function [wash_in_slope, wash_out_slope, area_under_curve, post_contrast_img, time_vals] = get_empirical_params(slices_mat_or_vec, info, t)
% Get empirical parameters
% [wash_in_slope, wash_out_slope, area_under_curve, time_vals] = get_empirical_params(slices_mat_or_vec, info, t)
% 
% INPUTS
% slices_mat_or_vec: either an NxMxK matrix of NxM-size images at K time points or a
%  NxK matrix of N pixels at K time points
% info: K-length info struct
% t: K-length vector of times

% OUTPUTS
% wash_in_slope: slope of contrast curve from 40 sec to 72 sec (contrast
%  units/min)
% wash_out_slope: slope of contrast curve from 40 sec to 180 sec (contrast
%  units/min)
% area_under_curve: area under curve up to 180 sec, divided by 180 sec
% (contrast units)

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
% Assert last dimension of slices corresponds to time dimension
assert(size(slices_mat_or_vec, ndims(slices_mat_or_vec)) == length(t));

%% Choose time points
[t1, t2, t3, b_high_t_res] = get_empirical_time_points(info, t);
time_vals = [t1 t2 t3];

%% Get 3 time-point values
% Convert image into KxR matrix of R pixels at K time points
if ndims(slices_mat_or_vec) > 2
  slices_vec = reshape(slices_mat_or_vec, size(slices_mat_or_vec, 1)*size(slices_mat_or_vec, 2), size(slices_mat_or_vec, 3)).';
else
  slices_vec = slices_mat_or_vec.';
end

% area_under_curve = sum(slices(:,t <= t3), 3)/max(t(t <= t3)); % Contrast units

% This is really the mean, but that's better for normalization among
% different inter-slice intervals
area_under_curve = mean(slices_mat_or_vec(:, t >= t1 & t <= t3), 2);

% If inter-slice spacing is very low (< 30 seconds), we'll average slices
% across time points; otherwise, we'll choose a single time point (or an
% interpolation between two time points)
if b_high_t_res
  t1_idx = t <= t1;
  t2_idx = abs(t - t2) <= 30; % Within 30 sec radius of t2
  t3_idx = t >= t3 - 60; % Within 60 seconds before t3
  if ~any(t1_idx) || ~any(t2_idx) || ~any(t3_idx)
    error('t1, t2 or t3 ranges are missing time points');
  end
  
  ampl1 = mean(slices_vec(t1_idx, :), 1);
  ampl2 = mean(slices_vec(t2_idx, :), 1);
  ampl3 = mean(slices_vec(t3_idx, :), 1);
else
  empirical_ampl = interp1(t, slices_vec, [t1 t2 t3]).';
  ampl1 = empirical_ampl(:,1); % Initial amplitude
  ampl2 = empirical_ampl(:,2); % Amplitude after wash-in
  ampl3 = empirical_ampl(:,3); % Final amplitude
end

wash_in_slope = (ampl2 - ampl1)/(t2 - t1)*60; % Contrast units/min
wash_out_slope = (ampl3 - ampl2)/(t3 - t2)*60; % Contrast units/min

% Just the post-contrast image (at time 2)
post_contrast_img = ampl2;

%% Reshape
if ndims(slices_mat_or_vec) > 2
  wash_in_slope = reshape(wash_in_slope, size(slices_mat_or_vec(:,:,1)));
  wash_out_slope = reshape(wash_out_slope, size(slices_mat_or_vec(:,:,1)));
  post_contrast_img = reshape(post_contrast_img, size(slices_mat_or_vec(:,:,1)));
end

if all(~isfinite(area_under_curve))
  warning('area under curve is 0');
end
