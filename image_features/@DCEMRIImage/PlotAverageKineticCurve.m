function PlotAverageKineticCurve(obj, varargin)
% Plot a lesion-averaged kinetic curve

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

%% Parse input parameters
p = inputParser;
p.addParamValue('b_show_empirical_map', true);
p.addParamValue('h_fig', []);
p.parse(varargin{:});

%% Get relative enhancement data
roi_pixels = GetROIPixels(obj);
avg_intensity = mean(roi_pixels);
relative_enhancement = avg_intensity/avg_intensity(1);

%% Plot curve
if isempty(p.Results.h_fig)
  figure;
  if p.Results.b_show_empirical_map
    figure_grow(gcf, 1.7, 0.8);
  else
    figure_grow(gcf, 1.3, 0.8);
  end
else
  clf(p.Results.h_fig);
end

if p.Results.b_show_empirical_map
  s(1) = subplot(1, 2, 1);
end

% Plot kinetic curve
plot(obj.Time, relative_enhancement, 'k-s', 'markersize', 8, 'markerfacecolor', 'w');

% Overlay empirical time points
[t1, t2, t3, b_high_t_res] = GetEmpiricalTimePoints(obj);
hold on;
plot([t1, t2, t3], interp1(obj.Time, relative_enhancement, [t1, t2, t3]), 'ro', 'markerfacecolor', 'w', 'markersize', 10, 'linewidth', 2);

grid on;
xlabel('Sec');
ylabel('Enhancement Ratio');

%% Plot kinetic map
if p.Results.b_show_empirical_map
  s(2) = subplot(1, 2, 2);
  PlotEmpiricalMapHSV(obj, 'h_ax', s(2));
end

%% Finish
increase_font;
