function varargout = run_fdr(p_vals, varargin)
% Run false discovery rate calculation and make some plots
% [q, h_fig] = run_fdr(p_vals, feature_names, varargin)

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id: run_fdr.m 338 2013-07-10 17:20:35Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('feature_names', {});
p.addParamValue('b_fdr_plots', true);
p.addParamValue('b_plot_p_vals', true);
p.parse(varargin{:});

%% Remove invalid values
p_vals(isnan(p_vals)) = [];

%% Run FDR
[fdr, q] = mafdr(p_vals, 'showplot', false);
[~, idx_sort] = sort(p_vals);

%% Plot p-values
h_fig = [];

if p.Results.b_plot_p_vals
  h_fig(end+1) = figure;
  barh(p_vals);
  xlabel('p-value');
  if ~isempty(p.Results.feature_names)
    set(gca, 'ytick', 1:length(p.Results.feature_names), 'yticklabel', p.Results.feature_names);
  end
  hold on;
  plot(0.05*[1 1], [0 length(p_vals)+1], 'r--');
  set(gca, 'xscale', 'log');
  % grid on;
  figure_grow(gcf, 1.5);
end

%% Plot FDR results
if p.Results.b_fdr_plots
  h_fig(end+1) = figure;
  subplot(2, 2, 1);
  % hist_edges = logspace(log10(min(p_vals))*0.95, 0, 10);
  % n = histc(p_vals, hist_edges);
  % n = [n(1:end-2), n(end-1) + n(end)]; % Stuff the last value, which is the right edge of the rightmost bin, into the rightmost bin
  % bar_by_edges(hist_edges, n, 'baseline', 1);
  % set(gca, 'xscale', 'log', 'yscale', 'log', 'tickdir', 'out');
  % yl = [1 10^ceil(log10(max(n)))];
  % ylim(yl);
  numbins = max(10, freedman_diaconis(p_vals));
  hist(p_vals, numbins);
  set(findobj(gca, 'type', 'patch'), 'facecolor', [1 1 1]*0.9);
  hold on
  % plot(0.05*[1 1], yl, 'r--');

  % Plot expected value of bin heights for random p-val distribution
  % bin_widths = calculate_bin_widths(min(hist_edges), max(hist_edges), length(hist_edges) - 1);
  % bin_centers = 10.^(log10(hist_edges(1:end-1)) + diff(log10(hist_edges))/2);
  % x_random_p_dist = linspace(min(p_vals), 1, 100);
  % y_random_p_dist = bin_widths/sum(bin_widths)*sum(n);
  % plot(bin_centers, y_random_p_dist, 'color', [0 0.5 0]);

  xlabel('p-value');
  ylabel('Count');
  grid on;
  box on;

  subplot(2, 2, 2);
  plot(p_vals(idx_sort), q(idx_sort), 'k', 'linewidth', 2)
  xlabel('p-value');
  ylabel('q-value');
  grid on;

  subplot(2, 2, 3);
  [f, x] = ecdf(q);
  stairs(x, f*length(q), 'k', 'linewidth', 2);
  if var(q) > 1e-4
    xlim(quantile(q, [0 1]));
  end
  xlabel('q-value');
  ylabel('# significant features');
  grid on;

  subplot(2, 2, 4);
  plot(1:length(q), flatten((1:length(q))).*flatten(q(idx_sort)), 'k', 'linewidth', 2);
  xlabel('# significant features');
  ylabel('# false positives');
  grid on;

  % subplot(2, 2, 4);
  % [~, idx_sort] = sort(p_vals);
  % plot(p_vals(idx_sort), fdr(idx_sort), 'linewidth', 1)
  % xlabel('p-value');
  % ylabel('FDR');
  % grid on;

  figure_grow(gcf, 1.5);
  increase_font;
end

%% Output arguments
if nargout > 0
  varargout{1} = q;
end
if nargout > 1
  varargout{2} = h_fig;
end
