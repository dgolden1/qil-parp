function [moving_registered, tform, tform_xcoords, tform_ycoords] = register_image_intensity(moving, fixed, varargin)
% Register two images via intensity-based method (imregister)
% INPUTS
% moving: the image to transform
% fixed: the reference image
% 
% PARAMETERS
% modality_str: modality struct to be passed to imregconfig (either
%  'monomodal' or 'multimodal' (default))
% optimizer: custom optimizer object from imregconfig
% metric: custom metric object from imregconfig
% sub_img_x_lim: upper and lower bounds of sub-image (cropped portion of
%  main image) on which to calculate registration. Registration and tform matrix is
%  applied to entire image. Default: [1 size(fixed, 2)]
% sub_img_y_lim: Default: [1 size(fixed, 1)]
% b_show_result: true to show result of registration via imshowpair
% h_axes: vector of two axes handles in which to show results
% h_fig: figure handle in which to show results
% 
% OUTPUTS
% moving_registered: registered version of moving image, in the coordinate
%  system of fixed
% tform: transform struct

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Setup
addpath(fullfile(qilsoftwareroot, 'my_imregister')); % Like imregister, but returns transform matrix

%% Parse input arguments
p = inputParser;
p.addParamValue('modality_str', 'multimodal');
p.addParamValue('optimizer', []);
p.addParamValue('metric', []);
p.addParamValue('sub_img_x_lim', [1 size(fixed, 2)]);
p.addParamValue('sub_img_y_lim', [1 size(fixed, 1)]);
p.addParamValue('b_show_result', false);
p.addParamValue('h_axes', []);
p.addParamValue('h_fig', []);

p.parse(varargin{:});
modality_str = p.Results.modality_str;
optimizer = p.Results.optimizer;
metric = p.Results.metric;
sub_img_x_lim = p.Results.sub_img_x_lim;
sub_img_y_lim = p.Results.sub_img_y_lim;
b_show_result = p.Results.b_show_result;
h_axes = p.Results.h_axes;
h_fig = p.Results.h_fig;

if isempty(optimizer)
  [optimizer, ~] = imregconfig(modality_str);
end
if isempty(metric)
  [~, metric] = imregconfig(modality_str);
end

%% Register sub-images
% Extract sub-images
fixed_sub = fixed(sub_img_y_lim(1):sub_img_y_lim(2), sub_img_x_lim(1):sub_img_x_lim(2));
moving_sub = moving(sub_img_y_lim(1):sub_img_y_lim(2), sub_img_x_lim(1):sub_img_x_lim(2));

% Register sub-images
[moving_sub_registered, tform] = my_imregister(moving_sub, fixed_sub, 'rigid', optimizer, metric, 'DisplayOptimization', false);

%% Apply transform to full image
% Get coordinates of full images in sub-image coordinate system (where
% upper-left pixel of sub-image is (1,1))
tform_xcoords = [2 - sub_img_x_lim(1), 1 - sub_img_x_lim(1) + size(moving, 2)];
tform_ycoords = [2 - sub_img_y_lim(1), 1 - sub_img_y_lim(1) + size(moving, 1)];

moving_registered = imtransform(moving, tform, 'UData', tform_xcoords, 'VData', tform_ycoords, ...
                                'XData', tform_xcoords, 'YData', tform_ycoords, 'XYScale', 1);

%% Show result
if b_show_result
  if isempty(h_axes)
    if isempty(h_fig)
      figure;
      figure_grow(gcf, 2, 1.5);
    else
      sfigure(h_fig);
      clf;
    end
  end
  
  if isempty(h_axes)
    s(1) = super_subplot(1, 2, 1);
  else
    s(1) = h_axes(1);
    saxes(s(1));
  end
  imshowpair(moving, fixed);
  title('Original');

  if isempty(h_axes)
    s(2) = super_subplot(1, 2, 2);
  else
    s(2) = h_axes(2);
    saxes(s(2));
  end
  imshowpair(moving_registered, fixed);
  title('Registered');

  linkaxes(s);
  zoom on;
end
