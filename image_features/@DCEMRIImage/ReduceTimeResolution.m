function obj_reduced = ReduceTimeResolution(obj, varargin)
% Reduce time resolution by deleting some time points
% obj = ReduceTimeResolution(obj, varargin)
% 
% PARAMETERS
% num_pts: final number of time points, including pre-contrast image (default: 5)
% sec_after_contrast: time after contrast injection of first post-contrast image
%  (default: 90)
% dt: time between successive images (default: 70)
% b_interpolate: (default: true) most high-time most high-time-resolution images have a big gap between
%  the wash-in and wash-out phases, so interpolation of the image will be necessary
%  across the gap. The image stack needs to be registered for this to work properly. If
%  b_interpolate is false, nearest neighbor interpolation will be used instead, which
%  will most likely result in non-uniform dt (with a giant gap in the middle)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('num_pts', 5);
p.addParamValue('sec_after_contrast', 90);
p.addParamValue('dt', 70)
p.addParamValue('b_interpolate', true)
p.parse(varargin{:});

%% Setup
if length(obj.Time) == p.Results.num_pts
  return;
elseif length(obj.Time) < p.Results.num_pts
  error('Image has fewer time points (%d) than requested (%d)', length(obj.Time), p.Results.num_pts);
end

%% Get contrast injection time
injection_time_sec = GetContrastInfo(obj);

%% Choose new time points
t = nan(1, p.Results.num_pts);

% First time point is last pre-contrast time point
t(1) = obj.Time(find(obj.Time < injection_time_sec, 1, 'last'));

t(2) = injection_time_sec + p.Results.sec_after_contrast;

t(3:end) = t(2) + p.Results.dt*(1:(p.Results.num_pts - 2));

% If we're not interpolating, find the nearest time values from the existing series and
% ensure they're unique
if ~p.Results.b_interpolate
  t = obj.Time(interp1(obj.Time, 1:length(obj.Time), t, 'nearest'));
  t = unique(t);
end

%% Reduce time resolution
% Permute is necessary because interp1 operates on the first dimension of Y
obj_reduced = obj;
obj_reduced.ImageStack = permute(interp1(obj.Time, permute(obj.ImageStack, [3 1 2]), t), [2 3 1]);

if ~isempty(obj.ImageStackUnregistered)
  obj_reduced.ImageStackUnregistered = permute(interp1(obj.Time, permute(obj.ImageStackUnregistered, [3 1 2]), t), [2 3 1]);
end

obj_reduced.Time = t;

% Just copy the first info struct and remove the timing information, because I don't
% want to set it
info_struct = obj.ImageInfo(1);
info_struct.SeriesDescription = [info_struct.SeriesDescription ' reduced time res'];
obj_reduced.ImageInfo = rmfield(repmat(info_struct, 1, length(t)), 'TriggerTime');

%% Re-create kinetic maps
obj_reduced = obj_reduced.CreateEmpiricalMaps;
obj_reduced = obj_reduced.CreatePKMaps;
