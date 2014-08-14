
function [MR_signals, msg] = synthesise_MR_signal_from_Tofts_model(PK_params_pairs, PK_params_type, time_vec, AIF_onset_time, ...
                                                                   Gd_dose, R1, R2, flip_angle, TR, TE, T10, M0)

global log_file log_window_handle

MR_signals = []; msg1 = [];

Gd_conc_signals = synthesise_Gd_conc_from_Tofts_model(PK_params_pairs, PK_params_type, time_vec, AIF_onset_time, Gd_dose);
[MR_signals, msg] = compute_MR_signal_from_Gd_conc(Gd_conc_signals, R1, R2, flip_angle, TR, TE, T10, M0);
error(msg);
