function enhancement_matrix = synthesise_MR_enhancement_from_Tofts_model(PK_params_pairs, PK_params_type, time_vec, AIF_onset_time, ...
                                                                                 Gd_dose, R1, R2, flip_angle, TR, TE, T10, varargin)

% Function originally by Nick Hughes (nhughes at stanford dot edu)
% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

% Forward synthesise Gd conc for the given PK params pairs
if length(varargin) == 2
  a = varargin{1}; m = varargin{2};
  Gd_conc_matrix = synthesise_Gd_conc_from_Tofts_model(PK_params_pairs, PK_params_type, time_vec, AIF_onset_time, Gd_dose, a, m);
else
  Gd_conc_matrix = synthesise_Gd_conc_from_Tofts_model(PK_params_pairs, PK_params_type, time_vec, AIF_onset_time, Gd_dose);
end

% % Get an index (into the time vec) corresponding to the CA injection time
% AIF_onset_time_idx = length(find(time_vec <= AIF_onset_time));

% Get an index into the time vector corresponding to the first image taken
% after contrast has been injected (logic changed by DIG 2012-02-20)
AIF_onset_time_idx = find(time_vec >= AIF_onset_time, 1, 'first');

% Compute the MR enhancement from the Gd conc matrix
enhancement_matrix = compute_MR_enhancement_from_Gd_conc(Gd_conc_matrix, R1, R2, flip_angle, TR, TE, T10, AIF_onset_time_idx);

1;
