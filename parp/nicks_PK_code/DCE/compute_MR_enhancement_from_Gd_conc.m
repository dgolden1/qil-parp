function enhancement_matrix = compute_MR_enhancement_from_Gd_conc(Gd_conc_matrix, R1, R2, flip_angle, TR, TE, T10, AIF_onset_time_idx)

% Function originally by Nick Hughes
% Modified by Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

if ~exist('AIF_onset_time_idx', 'var') || isempty(AIF_onset_time_idx)
  AIF_onset_time_idx = 2;
end

num_voxels = size(Gd_conc_matrix, 1);
T = size(Gd_conc_matrix, 2);

% Check that the CA concentration is zero at the first time step
if any(Gd_conc_matrix(:,1)>0)
  error('CA conc value at t=0 is > 0... MR enhancement calculations assume pre-contrast at t=0...');
end
	
% Check that only a single T10 value is passed
if length(T10) > 1
  error('Function only defined for scalar T10');
end

% Check that TR and TE are given in the correct units (seconds)
if TR > 1 || TE > 1
  error('TR and TE must be specified in seconds, not milliseconds...');
end

% Check that T10 value is a valid number
if T10 < 0 || isnan(T10) || isinf(T10)
  error('Invalid T10 value of %f', T10);
end

% Sanity check on tissue relaxivities R1 and R2 - values should be in s^{-1} mM^{-1}
if R1 < 0 || R1 > 10
  error('Invalid value for R1 relaxivity: %1.1f', R1);
end

if R2 < 0 || R2 > 10
  error('Invalid value for R2 relaxivity: %1.1f', R2);
end

% Compute the MR signal matrix (assume M0 = 1), then the enhancement matrix from this
signal_matrix = compute_MR_signal_from_Gd_conc(Gd_conc_matrix, R1, R2, flip_angle, TR, TE, T10, 1.0);
enhancement_matrix = compute_MR_enhancement_from_MR_signal(signal_matrix, AIF_onset_time_idx);
