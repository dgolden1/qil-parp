
function valid = check_DCE_MRI_data_struct(DCE_MRI_Struct)

valid = false;

if isfield(DCE_MRI_Struct, 'Data')
  if iscell(DCE_MRI_Struct.Data)
    num_volumes = length(DCE_MRI_Struct.Data);
  else
    disp('"Data" field within DCE-MRI data struct should be a cell array');
    return;
  end
else
  disp('DCE-MRI data struct does not contain the field "volume_data"');
  return;
end

if isfield(DCE_MRI_Struct, 'sample_times')
  if length(DCE_MRI_Struct.sample_times) ~= num_volumes
    disp('number of sample times should match the number of MR volumes');
    keyboard
    return;
  end
else
  disp('DCE-MRI data struct does not contain the field "sample_times"');
  return;
end

if isfield(DCE_MRI_Struct, 'is_baseline_volume')
  if length(DCE_MRI_Struct.is_baseline_volume) ~= num_volumes
    disp('number of sample times should match the number of MR volumes');
    keyboard
    return;
  end
else
  disp('DCE-MRI data struct does not contain the field "is_baseline_volume"');
  return;
end

if isfield(DCE_MRI_Struct, 'flip_angle')
  if DCE_MRI_Struct.flip_angle < 0 || DCE_MRI_Struct.flip_angle > 90
    disp('Flip angle in DCE-MRI data struct is not in the range [0,90]');
    return;
  end
else
  disp('DCE-MRI data struct does not contain a field for "flip_angle"');
  return;
end

if isfield(DCE_MRI_Struct, 'TR')
  if DCE_MRI_Struct.TR < 0
    disp('Repetition time (TR) in DCE-MRI data struct is negative');
    return;
  end
else
  disp('DCE-MRI data struct does not contain a field for "TR"');
  return;
end

if isfield(DCE_MRI_Struct, 'TE')
  if DCE_MRI_Struct.TE < 0
    disp('Echo time (TE) in DCE-MRI data struct is negative');
    return;
  end
else
  disp('DCE-MRI data struct does not contain a field for "TE"');
  return;
end

if isfield(DCE_MRI_Struct, 'Gd_dose')
  if DCE_MRI_Struct.Gd_dose < 0
    disp('Gadolinium dose in DCE-MRI data struct is negative');
    return;
  end
else
  disp('DCE-MRI data struct does not contain a field for "Gd_dose"');
  return;
end

valid = true;
