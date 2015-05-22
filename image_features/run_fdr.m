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
  subplot(1, 2, 1);

  numbins = max(10, freedman_diaconis(p_vals));
  hist(p_vals, numbins);
  set(findobj(gca, 'type', 'patch'), 'facecolor', [1 1 1]*0.9);
  hold on
  
  xlabel('p-value');
  ylabel('Count');
  grid on;
  box on;

  subplot(1, 2, 2);
  [f, x] = ecdf(q);
  stairs(x, f*length(q), 'k', 'linewidth', 2);
  if var(q) > 1e-4
    xlim(quantile(q, [0 1]));
  end
  xlabel('q-value');
  ylabel('# significant features');
  grid on;

  figure_grow(gcf, 1.5, 1);
  increase_font;
end

%% Output arguments
if nargout > 0
  varargout{1} = q;
end
if nargout > 1
  varargout{2} = h_fig;
end
