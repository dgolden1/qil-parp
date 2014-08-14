function [ktrans, ve, kep, residual, model] = fit_Tofts_model_using_known_T10_at_voxel(time_vec, enhancement_data, AIF_onset_time, ...
																																																		Gd_dose, R1, R2, flip_angle, TR, TE, T10)

% Function originally by Nick Hughes (nhughes at stanford dot edu)
% Modified by Daniel Golden (dgolden1 at stanford dot edu)
% $Id$

% Tofts_forward_model = @(PK_param_vec, t) synthesise_MR_enhancement_from_Tofts_model(PK_param_vec, 'Ktrans ve', t, AIF_onset_time, Gd_dose, R1, R2, flip_angle, TR, TE, T10);
Tofts_forward_model = @(PK_param_vec, t) synthesise_MR_enhancement_from_Tofts_model(PK_param_vec, 'Ktrans kep', t, AIF_onset_time, Gd_dose, R1, R2, flip_angle, TR, TE, T10);

init_ktrans = 1;
init_kep = 1;
% init_ktrans = 0.5;
% init_ve = 0.5;

% These bounds seem logical given Figure 3 from Tofts and Kermode 1991
% doi:10.1002/mrm.1910170208
% lower_bounds = [1 1]*1e-3;
% upper_bounds = [1 1]*1e-1;

% These bounds are awfully liberal
% lower_bounds = [0 0.1];
% upper_bounds = [2 1];

% These bounds are liberal to the point of being non-physical. This is
% necesary if I don't know T10
% ktrans_min = 0;
% ktrans_max = 10;
% ve_min = 0.1;
% ve_max = 3;
% lower_bounds = [ktrans_min ve_min];
% upper_bounds = [ktrans_max ve_max];

% These are the old values which also have no basis in reality
ktrans_min = .1;
ktrans_max = 2.5;
kep_min = .1;
kep_max = 2.5;
lower_bounds = [ktrans_min kep_min];
upper_bounds = [ktrans_max kep_max];


% [params, residual] = lsqcurvefit(Tofts_forward_model, [init_ktrans init_ve], time_vec, enhancement_data, lower_bounds, upper_bounds, opts);
% 
% ktrans = params(1);
% ve =  params(2);
% kep = ktrans/ve;

% In the future, I'll consider changing TolFun to speed this process up
% Speed Test (with patient 2, 1021 voxels, Dan's MacBook Pro)
% TolFun = 1e-6: 106 sec
% TolFun = 1e-3: 56 sec
% PK maps do actually look different; I should probably leave TolFun at
% 1e-6
opts = optimset('lsqcurvefit');
opts = optimset(opts, 'Display', 'none', 'TolFun', 1e-6);
[params, residual] = lsqcurvefit(Tofts_forward_model, [init_ktrans init_kep], time_vec, enhancement_data, lower_bounds, upper_bounds, opts);

ktrans = params(1);
kep =  params(2);
ve = ktrans/kep;

model.t_fit = linspace(0, max(time_vec), 100);
model.enhancement_fit = Tofts_forward_model(params, model.t_fit);
model.t_data = time_vec;
model.enhancement_data = enhancement_data;

% Plot actual curve and fit
if false
  figure(1);
  plot(model.t_data, model.enhancement_data, 'rs-', model.t_fit, model.enhancement_fit, 'b-');
  grid on;
  legend('Data', 'Fit');
  xlabel('Time (min)');
  ylabel('Enhancement');
  title(sprintf('K_{trans} = %G, k_{ep} = %G, v_e = %0.1f', ktrans, kep, ve));
  increase_font;
end

1;
