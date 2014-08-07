function varargout = plot_survival(times, b_censored, varargin)
% Make Kaplan-Meier survival plot with censoring marks
% h = plot_survival(times, b_censored, 'param', value, ...)
% 
% OUTPUTS
% handles to plotted elements (survival curve, confidence bounds, at risk)
% 
% PARAMETERS
% b_plot_at_risk: Include a curve showing number at risk (default: false)
% time_units: Units of time to be plotted (e.g., 'months') (default: 'Time')
% b_legend: include a legend (default: false)
% b_plot_hazard: plot cumulative hazard function (default: false)
% color: line color
% h_ax: axes handles on which to plot (default: make new figures). If b_plot_hazard is
%  true, then h_ax must have length 2

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id: plot_survival.m 343 2013-07-13 00:04:54Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('time_units', 'Time');
p.addParamValue('b_plot_at_risk', false); 
p.addParamValue('b_legend', false);
p.addParamValue('b_plot_hazard', false);
p.addParamValue('color', []);
p.addParamValue('h_ax', []);
p.parse(varargin{:});

if isempty(p.Results.color)
  survivor_color = 'b';
  censor_color = 'r';
  confidence_color = [1 1 1]*0.5;
  at_risk_color = 'k';
else
  survivor_color = p.Results.color;
  censor_color = p.Results.color;
  confidence_color = p.Results.color;
  at_risk_color = 'k';
end

%% Plot survivor functions
if ~isempty(p.Results.h_ax)
  saxes(p.Results.h_ax);
else
  figure;
end

% Get survivor function
if all(b_censored)
  % ecdf fails if all observations are censored
  f = [1 1]';
  x = quantile(times, [0 1]');
  flo = nan(size(f));
  fup = nan(size(f));
else
  [f, x, flo, fup] = ecdf(times, 'censoring', b_censored, 'function', 'survivor', 'bounds', 'on');
end

% Include left and right bound
if x(1) ~= 0
  x = [0; x];
  f = [1; f];
  flo = [nan; flo];
  fup = [nan; fup];
end
f(end+1) = f(end);
flo(end+1) = flo(end);
fup(end+1) = fup(end);
x(end+1) = max(times);

% Plot survivor function
[xb, yb] = stairs(x, f);
h(1) = plot(xb, yb, 'color', survivor_color);
legend_str{1} = 'Survivor';
hold on;

% Plot confidence bounds
h(2) = stairs(x, flo, '--', 'color', confidence_color);
stairs(x, fup, '--', 'color', confidence_color);
legend_str{2} = '95% conf';

if p.Results.b_plot_at_risk
  % Survivor function showing percent at risk
  [f_at_risk, x_at_risk] = ecdf(times, 'function', 'survivor');

  % Plot number at risk
  h(end+1) = stairs(x_at_risk, f_at_risk, ':', 'color', at_risk_color);
  legend_str{end+1} = 'At risk';
end

% Plot censoring points
censored_months = times(b_censored);
xb_unique = xb + 1e-6*(1:length(xb)).';
plot(censored_months, interp1(xb_unique, yb, censored_months), '+', 'color', censor_color);

xlabel(p.Results.time_units);
ylabel('Proportion');
grid on;

if p.Results.b_legend
  legend(h, legend_str, 'location', 'east');
end

set(findobj(gca, 'type', 'line'), 'linewidth', 2);

if isempty(p.Results.h_ax)
  increase_font;
end

%% Plot cumulative hazard functions
if p.Results.b_plot_hazard
  if length(p.Results.h_ax) >= 2
    saxes(p.Results.h_ax(2));
  else
    figure;
    figure_grow(gcf, 2, 1);
  end
  
  % Plot cumulative hazard function
  ecdf(times, 'censoring', b_censored, 'function', 'cumulative hazard', 'bounds', 'on');

  set(findobj(gca, 'type', 'line'), 'linewidth', 2);
  xlabel('Months');
  ylabel('Cumulative Hazard');
  grid on

  if length(p.Results.h_ax) < 2
    increase_font;
  end
end

%% Output arguments
if nargout > 0
  varargout{1} = h;
end

1;