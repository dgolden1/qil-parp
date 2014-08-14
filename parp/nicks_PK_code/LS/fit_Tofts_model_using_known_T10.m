function [Ktrans, ve, kep, residual, model] = fit_Tofts_model_using_known_T10(DCE_MRI_Struct, voxel_idx, AIF_onset_time, num_runs_optimiser, ...
																																			 init_Ktrans, init_kep, T10_values, b_parallel)
% For more explanation of Ktrans, ve and kep, see Tofts 1999
% (doi:10.1002/(SICI)1522-2586(199909)10:3<223::AID-JMRI2>3.0.CO;2-S)
% For more explanation of modeling, see Tofts and Kermode 1991
% (doi:10.1002/mrm.1910170208)
                                                                     
% OUTPUTS
% Ktrans: volume transfer constant between blood plasma and EES (1/min)
% kep: rate constant between EES and blood plasma (1/min)
% ve: Volume of extravascular extracellular space per unit volume of tissue
%  (unitless, 0 < ve < 1)
% 
% kep = Ktrans/ve
% kep > Ktrans
% Typically, 2*Ktrans < kep < 5*Ktrans
                                                                     
% Function originally by Nick Hughes (nhughes at stanford dot edu)
% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

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

if b_parallel
  if matlabpool('size') == 0
    matlabpool('open');
  end
  
  fprintf('Modeling PK parameters for %d voxels in parallel... ', length(voxel_idx));
  
  parfor n=1:length(voxel_idx)
    [Ktrans(n, 1), ve(n, 1), kep(n, 1), residual(n, 1), model(n, 1)] = fit_Tofts_model_using_known_T10_at_voxel(...
      time_vec, enhancement_matrix(n,:), AIF_onset_time, Gd_dose, R1, R2, flip_angle, ...
      TR, TE, T10_values(n));
  end

  fprintf('done\n');
else
  h_waitbar = waitbar(0, sprintf('Processed voxel %d of %d', 0, length(voxel_idx)));
  
  for n=1:length(voxel_idx)
    t_voxel_start = now;

    [Ktrans(n, 1), ve(n, 1), kep(n, 1), residual(n, 1), model(n, 1)] = fit_Tofts_model_using_known_T10_at_voxel(...
      time_vec, enhancement_matrix(n,:), AIF_onset_time, Gd_dose, R1, R2, flip_angle, ...
      TR, TE, T10_values(n));
    
    waitbar(n/length(voxel_idx), h_waitbar, sprintf('Processed voxel %d of %d', n, length(voxel_idx)));
    %   fprintf('Processed voxel %d of %d in %s\n', n, length(voxel_idx), time_elapsed(t_voxel_start, now));
  end
  close(h_waitbar);
end

1;
