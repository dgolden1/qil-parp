function [MR_signals, msg] = compute_MR_signal_from_Gd_conc(Gd_conc_signals, R1, R2, flip_angle, TR, TE, T10, M0)

MR_signals = []; msg = [];

[num_voxels, T] = size(Gd_conc_signals);

% Check that only a single T10 and M0 value is passed
if length(T10) > 1 || length(M0) > 1
  error('Function %s only defined for scalar T10 and M0', mfilename);
end

% Check that TR, TE and T10 are all given in the correct units (seconds)
if (TR > 1 || TE > 1 || sum(T10 > 100))
  error('TR / TE / T10 must be specified in seconds, not milliseconds...');
end

% Sanity check on tissue relaxivities R1 and R2 - values should be in s^{-1} mM^{-1}
if R1 < 0 || R1 > 10
  error('Invalid value for R1 relaxivity: %1.1f', R1);
end

if R2 < 0 || R2 > 10
  error('Invalid value for R2 relaxivity: %1.1f', R2);
end

% Compute P and Q terms need in enhancement calculation (see Armitage p.317) 
P = repmat(TR/T10, num_voxels, T);
Q = R1*Gd_conc_signals*TR;

% Compute cos and sin of flip angle
cos_alpha = cos(2*pi*flip_angle/360);
sin_alpha = sin(2*pi*flip_angle/360);

% Compute MR signal - assume TE << T2*
M = M0 * exp(-R2*Gd_conc_signals*TE);
MR_signals =  M  * sin_alpha .* ((1 - exp(-P-Q))./(1 - cos_alpha*exp(-P-Q)));
