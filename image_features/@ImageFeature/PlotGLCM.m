function PlotGLCM(obj, varargin)
% Plot the GLCM matrix

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: PlotGLCM.m 185 2013-02-13 01:42:05Z dgolden $

%% Parse Input Arguments
p = inputParser;
p.addParamValue('h_fig', []);
p.parse(varargin{:});

%% Get average GLCM
[~, glcm] = GetFeatureGLCM(obj);
glcm_avg = sum(glcm, 3);

%% Plot
if ~isempty(p.Results.h_fig)
  sfigure(p.Results.h_fig);
else
  figure;
  figure_grow(gcf, 1.5, 1);
end

subplot(1, 2, 1);
PlotImage(obj, 'h_ax', gca);
title(obj.ImagePrettyName);

subplot(1, 2, 2);
imagesc(glcm_avg);
axis square xy;
title('GLCM');
