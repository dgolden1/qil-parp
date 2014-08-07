function t = get_dicom_time(info, patient_id)
% Get acquisition time from DICOM info struct
% t = get_dicom_time(info)
% 
% t is a Matlab datenum

% By Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

%% Setup
if isnumeric(patient_id)
  % String patient IDs only
  patient_id = num2str(patient_id, '%03d');
end

%% Calculate time
if isfield(info, 'AcquisitionTime') && isfield(info, 'AcquisitionDate')
  % MRI and PET images seem to have these properties
  acquisition_time_cell = {info.AcquisitionTime};
  acquisition_date_cell = {info.AcquisitionDate};
elseif isfield(info, 'SeriesTime') && isfield(info, 'AcquisitionDate')
  % CT images seem to have these properties
  acquisition_time_cell = {info.SeriesTime};
  acquisition_date_cell = {info.SeriesDate};
else
  t = nan(size(info));
  return;
end

for kk = 1:length(acquisition_time_cell)
  acquisition_time(kk) = datenum([...
                                  str2double(acquisition_date_cell{kk}(1:4)), ...
                                  str2double(acquisition_date_cell{kk}(5:6)), ...
                                  str2double(acquisition_date_cell{kk}(7:8)), ...
                                  str2double(acquisition_time_cell{kk}(1:2)), ...
                                  str2double(acquisition_time_cell{kk}(3:4)), ...
                                  str2double(acquisition_time_cell{kk}(5:6))]);
end

t = acquisition_time;
if isfield(info, 'TriggerTime')
  % The WATER:one touch T1 map BIG sequence (e.g., 052-POST) has images
  % without a trigger time for some reason
  % Somehow, OsiriX seems to put them in the correct order, but I don't
  % know how
  trigger_time_cell = {info.TriggerTime};
  idx_valid = ~cellfun(@isempty, trigger_time_cell);

  t(idx_valid) = t(idx_valid) + [info.TriggerTime]/86400000; % TriggerTime is in ms
  t(~idx_valid) = nan;
end

series_name = info(1).SeriesDescription;

%% Kludges for when the above procedure doesn't work
if strcmp(series_name, 'WATER:DISCO 3 reg (old)') || strcmp(series_name, 'WATER:DISCO 4D') && any(isnan(t)) && strcmp(patient_id, '107')
  % As info(:) index increases, we move first across slices, then across
  % time points
  num_slices = length(unique([info.SliceLocation]));
  num_time_points = length(info)/num_slices;
  t_mat = zeros(num_slices, num_time_points);
  
  dt_med = nanmedian(diff(unique(t(isfinite(t)))));
  
  % According to Manoj (manojsar@stanford.edu) from the Sep 16, 2012
  % e-mail thread, in the "undorked" images, dt is set to the time
  % between high spatial-res images. The time between the high
  % time-res images is the high spatial-res time multiplied by 0.16*0.44
  if dt_med > 30/86400
    dt_htr = dt_med*0.16*0.44; % high time-res
    dt_ltr = dt_med;
  else
    dt_htr = dt_med;
    dt_ltr = dt_med/(0.16*0.44);
  end
  
  t0 = min(t);
  
  if strcmp(series_name, 'WATER:DISCO 3 reg (old)')
    % I figured this out empirically in OsiriX; there are 15 high-time-res images
    % followed by 9 low-time-res images for patient 058-PRE
    b_high_time_res = [true(1, 15), false(1, 9)];
  elseif strcmp(series_name, 'WATER:DISCO 4D') && any(isnan(t)) && patient_id == 107
    % 19 high-time-res images and 4 low-time-res images
    b_high_time_res = [true(1, 19), false(1, 4)];
  end
  
  if num_time_points == length(b_high_time_res)
    % Get start time for each image
    dt = b_high_time_res(1:end-1)*dt_htr + ~b_high_time_res(1:end-1)*dt_ltr;
    t_vec = t0 + [0 cumsum(dt)];
    
    % Assign start times for each member of info struct which is actually a
    % flattened matrix which goes first across slices, then across rows
    t_mat = t_mat + repmat(t_vec, num_slices, 1);
    t = reshape(t_mat, size(info));
  else
    error('Unexpected number of time points for WATER:DISCO 3 reg (old) (%d)\nImage times are questionable', length(t));
  end
end
1;
