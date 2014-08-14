function [best_Ktrans, best_ve, best_kep, best_T10, best_residual, timeTaken] = fit_Tofts_model_and_T10_at_voxel_new(time_vec, enhancement_data, AIF_onset_time, ...

% Function originally by Nick Hughes
% Modified by Daniel Golden (dgolden1 at stanford dot edu) February 2012
% $Id$

Gd_dose, field_strength, CA_type, flip_angle, TR, TE, varargin)
tic;
% Default settings
num_iters = 10;
disp(sprintf('TR value passed to me: %f', TR));
init_Ktrans_values = [0.1:0.01:2.5];
init_kep_values = [0.1:0.01:2.5];
init_T10_values = [0.1:0.01:2.0];

% added by Navneet
disp('sizes');
disp(size(enhancement_data));
disp(size(time_vec));
enhancement_data
time_vec
switch CA_type
	case 0
		CA_string = 'prohance';
	case 1
		CA_string = 'omniscan';
	case 2
		CA_string = 'magnevist';
	otherwise
	 	disp(sprintf('No corresponding type of agent for value %d', CA_type));
        return;
end

[R1,R2] = get_CA_relaxivities(CA_string, field_strength);

R1
R2
% finished adding code - Navneet

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
  rand_idx = randperm(length(init_Ktrans_values));
  init_Ktrans = init_Ktrans_values(rand_idx(1));

  rand_idx = randperm(length(init_kep_values));
  init_kep = init_kep_values(rand_idx(1));

  rand_idx = randperm(length(init_T10_values));
  init_T10 = init_T10_values(rand_idx(1));
  
  [params, residual] = lsqcurvefit(Tofts_forward_model, [init_Ktrans init_kep init_T10], time_vec, enhancement_data, lower_bounds, upper_bounds, opts);

  if (n == 1) || (residual < best_residual)
    best_residual = residual;
    best_Ktrans = params(1);
    best_kep = params(2);
    best_T10 = params(3);
    best_ve = best_Ktrans/best_kep;
  end
end

timeTaken=toc;
