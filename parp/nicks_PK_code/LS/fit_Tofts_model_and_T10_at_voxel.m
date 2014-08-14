function [best_Ktrans, best_ve, best_kep, best_T10, best_residual] = fit_Tofts_model_and_T10_at_voxel(time_vec, enhancement_data, AIF_onset_time, ...
																																																			Gd_dose, R1, R2, flip_angle, TR, TE, varargin)
% Function originally by Nick Hughes
% Modified by Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

% Default settings
num_iters = 10;
init_Ktrans_values = [0.1:0.01:2.5];
init_kep_values = [0.1:0.01:2.5];
init_T10_values = [0.1:0.01:2.0];

% Process optional arguments passed
for k=1:length(varargin)
  switch k
   case 1
    num_iters = varargin{k};
   case 2
    init_Ktrans_values = varargin{k};
   case 3
    init_kep_values = varargin{k};   
   case 4
    init_T10_values = varargin{k};  
   otherwise
    disp(sprintf('Oops - too many variable arguments passed to function %s', mfilename));
    return;
  end
end

% Set lower bounds for optimisation
lower_bounds = [min(init_Ktrans_values) min(init_kep_values) min(init_T10_values)];
upper_bounds = [max(init_Ktrans_values) max(init_kep_values) max(init_T10_values)];

opts = optimset('lsqcurvefit');
opts = optimset(opts, 'Display', 'none', 'TolX', 1e-2);

Tofts_forward_model = @(param_vec, t) synthesise_MR_enhancement_from_Tofts_model(param_vec(1:2), 'Ktrans kep', t, AIF_onset_time, ...
																																								 Gd_dose, R1, R2, flip_angle, TR, TE, param_vec(3));

for n=1:num_iters
%   rand_idx = randperm(length(init_Ktrans_values));
%   init_Ktrans = init_Ktrans_values(rand_idx(1));
% 
%   rand_idx = randperm(length(init_kep_values));
%   init_kep = init_kep_values(rand_idx(1));
% 
%   rand_idx = randperm(length(init_T10_values));
%   init_T10 = init_T10_values(rand_idx(1));

  init_Ktrans = (n-1)/(num_iters-1)*(init_Ktrans_values(end) - init_Ktrans_values(1)) + init_Ktrans_values(1);
  init_kep = (n-1)/(num_iters-1)*(init_kep_values(end) - init_kep_values(1)) + init_kep_values(1);
  init_T10 = (n-1)/(num_iters-1)*(init_T10_values(end) - init_T10_values(1)) + init_T10_values(1);

  [params(n, :), residual(n)] = lsqcurvefit(Tofts_forward_model, [init_Ktrans init_kep init_T10], time_vec, enhancement_data, lower_bounds, upper_bounds, opts);
end

[~, best_idx] = min(residual);
best_residual = residual(best_idx);
best_Ktrans = params(best_idx, 1);
best_kep = params(best_idx, 2);
best_T10 = params(best_idx, 3);
best_ve = best_Ktrans/best_kep;

% fprintf('Ktrans std = %g, Kep std = %g, T10 std = %g\n', std(params(:,1)), std(params(:,2)), std(params(:,3)));

1;
