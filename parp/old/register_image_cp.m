function [moving_registered, cp, tform] = register_image_cp(moving, fixed, varargin)
% Register one image with respect to a second image using manually-selected
% control points
% 
% INPUTS
% moving: the image to transform
% fixed: the reference image
% 
% PARAMETERS
% cp: control point struct with fields 'xyinput_out' and 'xybase_out',
%  containing previously-determined control points from the cpselect()
%  function. If not provided, cpselect() will be run
% tform: previously determined transform struct to use to transform the
%  moving image. If this is not provided, the control points will be used
% b_show_result: true to show result of registration via imshowpair
% h_fig: figure handle in which to show results
% 
% OUTPUTS
% moving_registered: registered version of moving image, in the coordinate
%  system of fixed
% cp: control points struct
% tform: transform struct

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('cp', []);
p.addParamValue('tform', []);
p.addParamValue('b_show_result', false);
p.addParamValue('h_fig', []);

p.parse(varargin{:});
cp = p.Results.cp;
tform = p.Results.cp;
b_show_result = p.Results.b_show_result;
h_fig = p.Results.h_fig;

%% Register
min_ctrl_pts = 3;

if isempty(tform)
  if isempty(cp)
    % Get control points
    % Image values must be between 0 and 1 for cpselect
    moving_norm = (moving - min(moving(:)))/range(moving(:));
    fixed_norm = (fixed - min(fixed(:)))/range(fixed(:));
    [cp.xyinput_out, cp.xybase_out] = cpselect(moving_norm, fixed_norm, 'Wait', true);
    
    if size(cp.xyinput_out, 1) < min_ctrl_pts
      error('register_image_cp:NotEnoughPoints', 'Not enough control points selected (%d < %d)', size(cp.xyinput_out, 1), min_ctrl_pts);
    end
  end
  
  % Create transform matrix
  tform = cp2tform(cp.xyinput_out, cp.xybase_out, 'affine');
end

% Transform, keeping registered "moving" image in the coordinate system of
% the "fixed" image
moving_registered = imtransform(moving, tform, 'XData', [1 size(fixed, 2)], 'YData', [1 size(fixed, 1)]);

%% Show result
if b_show_result
  if isempty(h_fig)
    figure;
    figure_grow(gcf, 2, 1.3);
  else
    sfigure(h_fig);
    clf;
  end
  
  s(1) = super_subplot(1, 2, 1);
  imshowpair(moving, fixed);
  title('Original');

  s(2) = super_subplot(1, 2, 2);
  imshowpair(moving_registered, fixed);
  title('Registered');

  linkaxes(s);
  zoom on;
end
