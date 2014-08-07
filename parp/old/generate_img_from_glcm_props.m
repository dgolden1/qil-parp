function [img, img_props] = generate_img_from_glcm_props(contrast, correlation, energy, homogeneity)
% Generate an image which nearly has the specified GLCM contrast,
% correlation, energy and homogeneity

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012

%% Setup
img_size = [6 6];

contrast = 3.43;
correlation = 0.68;
energy = 0.07;
homogeneity = 0.61;

%% Fit image

opt = optimset('lsqcurvefit');
opt = optimset(opt, 'DiffMinChange', 1/8);
img0 = rand(prod(img_size), 1); % Random initial image

% lower_bound = zeros(size(img0));
% upper_bound = ones(size(img0));
lower_bound = [];
upper_bound = [];


[img_fit, resnorm, residual] = lsqcurvefit(@(x, ~) get_glcm_props_from_img(reshape(x, img_size)), img0, ...
  nan(numel(img0), 1), [fwd_contrast_fcn(contrast), correlation, energy, homogeneity], lower_bound, upper_bound, opt);

x_fit = get_glcm_props_from_img(reshape(img_fit, img_size));
contrast_fit = rvs_contrast_fcn(x_fit(1));
correlation_fit = x_fit(2);
energy_fit = x_fit(3);
homogeneity_fit = x_fit(4);

1;

function x = get_glcm_props_from_img(img)
%% Function get glcm properties from an image

grayco_offsets = [0 1; -1 1; -1 0; -1 -1];
glcm = graycomatrix(img, 'Offset', grayco_offsets, 'symmetric', true);
props = graycoprops(glcm);

fn = fieldnames(props);
x = nan(1, length(fn));
for kk = 1:length(fn)
  x(kk) = mean(props.(fn{kk}));
  
  if strcmp(fn{kk}, 'Contrast')
    x(kk) = fwd_contrast_fcn(x(kk));
  end
end

function contrast_xform = fwd_contrast_fcn(contrast)
% Transform contrast so its range is closer to the other GLCM parameters

contrast_xform = (1.1.^contrast - 1)./1.1.^contrast;

function contrast = rvs_contrast_fcn(contrast_xform)

contrast = log(1./(1 - contrast_xform))./log(1.1);

1;
