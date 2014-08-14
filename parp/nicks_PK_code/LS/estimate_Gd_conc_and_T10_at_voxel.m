
function [Gd_conc_signal, T10, best_residual] = estimate_Gd_conc_and_T10_at_voxel(time_vec, enhancement_data, Gd_dose, R1, R2, flip_angle, TR, TE, varargin)

T = length(time_vec);

% Default settings
num_iters = 10;
T10_values = [0:0.01:3.0];

% Process optional arguments passed
for k=1:length(varargin)
  switch k
   case 1
    num_iters = varargin{k};
   case 2
    T10_values = varargin{k};  
   otherwise
    disp(sprintf('Oops - too many variable arguments passed to function %s', mfilename));
    return;
  end
end

% Set lower bounds for optimisation
Gd_conc_lb = 0; Gd_conc_ub = 10;
lower_bounds = [Gd_conc_lb * ones(1,T-1) T10_values(1)];
upper_bounds = [Gd_conc_ub * ones(1,T-1) T10_values(end)];

opts = optimset('lsqcurvefit');
opts = optimset('Display', 'none');

enhancement_model = @(param_vec, t) compute_MR_enhancement_from_Gd_conc([0 param_vec(1:end-1)], R1, R2, flip_angle, TR, TE, param_vec(end));

for n=1:num_iters
  init_Gd_conc_signal = Gd_conc_lb + Gd_conc_ub*rand(1,T-1);

  rand_idx = randperm(length(T10_values));
  init_T10 = T10_values(rand_idx(1));
  
  [param_vec, residual] = lsqcurvefit(enhancement_model, [init_Gd_conc_signal init_T10], time_vec, enhancement_data, lower_bounds, upper_bounds, opts);

  if (n == 1) || (residual < best_residual)
    best_residual = residual;
    Gd_conc_signal = [0 param_vec(1:end-1)];
    T10 = param_vec(end);
  end
end
