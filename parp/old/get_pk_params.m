function [ktrans, ve, kep, T10, residual, model, b_known_contrast_protocol] = get_pk_params(slices, roi_mask, t, info)
% Get pharmacokinetic parameters for a single lesion using Nick's code

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'parp', 'nicks_PK_code', 'DCE'));
addpath(fullfile(qilsoftwareroot, 'parp', 'nicks_PK_code', 'LS'));

%% Run Nick's PK code
[contrast_injection_time, chem_name, dose, b_known_contrast_protocol] = get_contrast_info(info, t);

DCE_MRI_Struct.Data = squeeze(mat2cell(slices, size(slices, 1), size(slices, 2), ones(1, size(slices, 3))));
DCE_MRI_Struct.sample_times = t/60; % min
DCE_MRI_Struct.is_baseline_volume = true(size(t)); DCE_MRI_Struct.is_baseline_volume(t > contrast_injection_time) = false;
DCE_MRI_Struct.field_strength = info(1).MagneticFieldStrength; % Tesla
DCE_MRI_Struct.flip_angle = info(1).FlipAngle; % deg
DCE_MRI_Struct.TR = info(1).RepetitionTime/1e3; % sec
DCE_MRI_Struct.TE = info(1).EchoTime/1e3; % sec
DCE_MRI_Struct.Gd_dose = dose; % mmol/kg
[DCE_MRI_Struct.R1, DCE_MRI_Struct.R2] = get_CA_relaxivities(chem_name, DCE_MRI_Struct.field_strength);

voxel_idx = find(roi_mask);

t_tofts_start = now;
AIF_onset_time = contrast_injection_time/60; % time of contrast agent injection, min
num_runs_optimizer = 1;
init_Ktrans = 1;
init_kep = 1;
% init_kep = init_Ktrans*3; % kep is 2-5 times higher than Ktrans -- Tofts 1999 doi:10.1002/(SICI)1522-2586(199909)10:3<223::AID-JMRI2>3.0.CO;2-S
% [ktrans, ve, kep, T10, residual] = fit_Tofts_model_and_T10(DCE_MRI_Struct, voxel_idx, AIF_onset_time, num_runs_optimizer, init_Ktrans, init_kep, init_T10);

% This is totally made up, but we don't know the real number and it's
% strongly dependent on ktrans; so the ktrans estimated from Nick's code
% is really a conglomeration of the true ktrans and the true T10
T10 = ones(size(voxel_idx));
b_parallel = true;

[ktrans, ve, kep, residual, model] = fit_Tofts_model_using_known_T10(DCE_MRI_Struct, voxel_idx, AIF_onset_time, num_runs_optimizer, init_Ktrans, init_kep, T10, b_parallel);
fprintf('Processed %d voxels in %s\n', length(voxel_idx), time_elapsed(t_tofts_start, now));

%% Deal with invalid values
% Sometimes kep and ktrans are really high; these values are invalid
idx_valid = kep < 3 & ktrans < 3;
kep(~idx_valid) = nan;
ktrans(~idx_valid) = nan;
ve(~idx_valid) = nan;

% I originally thought that kep must be between 0 and 1, but now I think
% this is false. ve, which is a unitless fractional volume, must be between
% 0 and 1 --DIG 2012-02-21
% kep = min(max(kep, 0), 1);

%% Plot per-voxel model output
if false
  % Plot each voxel and model
  for kk = 1:length(model)
    sfigure(1);
    clf
    plot(model(kk).t_data, model(kk).enhancement_data, 'rs-', model(kk).t_fit, model(kk).enhancement_fit, 'b-');
    grid on;
    legend('Data', 'Fit');
    xlabel('Time (min)');
    ylabel('Enhancement');
    title(sprintf('K_{trans} = %0.2G, k_{ep} = %0.2G, v_e = %0.1f', ktrans(kk), kep(kk), ve(kk)));
    increase_font;
    print('-dpng', '-r90', sprintf('/Users/dgolden/temp/enhancement/voxel%05d', kk));
  end

  kk = 1;
  figure;
  plot(model(kk).t_data, model(kk).enhancement_data, 'rs-', model(kk).t_fit, model(kk).enhancement_fit, 'b-');
  grid on;
  legend('Data', 'Fit');
  xlabel('Time (min)');
  ylabel('Enhancement');
  
  % Plot quantiles
  quantiles = [0.1 0.5 0.9];
  figure;
  h = plot(model(1).t_data, quantile(cell2mat({model.enhancement_data}.'), quantiles), 'rs-', ...
    model(1).t_fit, quantile(cell2mat({model.enhancement_fit}.'), quantiles), 'b-');
  grid on;
  legend(h([1 1+length(quantiles)]), {'Data', 'Fit'});
  xlabel('Time (min)');
  ylabel('Enhancement');
  
  % Histogram of Ktrans and kep
  figure;
  subplot(2, 2, 1);
  hist(ktrans, sqrt(length(ktrans)));
  grid on;
  xlabel('K_{trans}');
  subplot(2, 2, 3);
  hist(kep, sqrt(length(kep)));
  grid on;
  xlabel('k_{ep}');
  subplot(2, 2, [2 4]);
  scatter(ktrans, kep, 'o');
  hold on;
  line_lims = [0, min([max(ktrans), max(kep)])];
  plot(line_lims, line_lims, 'r-', 'linewidth', 2);
  grid on;
  xlabel('K_{trans}');
  ylabel('k_{ep}');
end

% I originally thought that kep must be between 0 and 1, but now I think
% this is false. ve, which is a unitless fractional volume, must be between
% 0 and 1 --DIG 2012-02-21
% kep = min(max(kep, 0), 1);
