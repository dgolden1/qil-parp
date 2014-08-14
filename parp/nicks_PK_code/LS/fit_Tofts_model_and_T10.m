function [Ktrans, ve, kep, T10, residual] = fit_Tofts_model_and_T10(DCE_MRI_Struct, voxel_idx, AIF_onset_time, num_runs_optimiser, init_Ktrans, init_kep, init_T10)

enhancement_matrix = compute_MR_enhancement_from_MR_volumes(DCE_MRI_Struct, voxel_idx, AIF_onset_time);

time_vec = DCE_MRI_Struct.sample_times;
flip_angle = DCE_MRI_Struct.flip_angle;

TR = DCE_MRI_Struct.TR;
TE = DCE_MRI_Struct.TE;

Gd_dose = DCE_MRI_Struct.Gd_dose;
R1 = DCE_MRI_Struct.R1;
R2 = DCE_MRI_Struct.R2;

if ~all(isfinite(enhancement_matrix(:)))
  error('NaNs or Infs found in enhancement vector');
end

for n=1:length(voxel_idx)
  t_voxel_start = now;

  [Ktrans(n), ve(n), kep(n), T10(n), residual(n)] = fit_Tofts_model_and_T10_at_voxel(...
    time_vec, enhancement_matrix(n,:), AIF_onset_time, Gd_dose, R1, R2, flip_angle, ...
    TR, TE, num_runs_optimiser, init_Ktrans, init_kep, init_T10);
  
  fprintf('Processed voxel %d of %d in %s\n', n, length(voxel_idx), time_elapsed(t_voxel_start, now));
end

