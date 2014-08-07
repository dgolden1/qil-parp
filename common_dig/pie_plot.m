function pie_plot(labels, varargin)
% Make a pie chart of some labels
% pie_plot(labels, 'param', value, ...)
% 
% PARAMETERS
% label_order: order of labels; should be the unique labels, in order
% h_ax: axis on which to plot

% By Daniel Golden (dgolden1 at stanford dot edu)
% $Id: pie_plot.m 219 2013-03-12 23:47:27Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('label_order', []);
p.addParamValue('colors', []);
p.addParamValue('h_ax', []);
p.parse(varargin{:});

%% Parse labels
nom = nominal(labels);
vals = levelcounts(nom);
pie_labels_orig = getlabels(nom);

if ~isempty(p.Results.label_order)
  if ~isequal(sort(pie_labels_orig(:)), unique(p.Results.label_order(:)))
    error('Ordered label contents does not match unique labels');
  end

  % Re-sort values and labels
  old_vals = vals; % Save for debugging
  old_pie_labels_orig = pie_labels_orig;
  
  for kk = 1:length(vals)
    this_src_idx = strcmp(old_pie_labels_orig, p.Results.label_order{kk});
    vals(kk) = old_vals(this_src_idx);
    pie_labels_orig(kk) = old_pie_labels_orig(this_src_idx);
  end
  
%   [~, sort_idx] = sort(p.Results.label_order);
%   [~, rank_idx] = sort(sort_idx);
%   vals = vals(rank_idx);
%   pie_labels_orig = pie_labels_orig(rank_idx);
end

%% Make labels for pie slices
for kk = 1:length(pie_labels_orig)
  pie_labels{kk} = sprintf('%s (%d, %0.0f%%)', pie_labels_orig{kk}, vals(kk), vals(kk)/sum(vals)*100);
end

%% Make figure
if isempty(p.Results.h_ax)
  figure;
else
  saxes(p.Results.h_ax);
end

h = pie(vals, pie_labels);

%% Assign colors
if ~isempty(p.Results.colors)
  colors = p.Results.colors;
  if iscell(colors)
    colors = colors(:);
  end
  
  if size(p.Results.colors, 1) < length(pie_labels_orig)
    error('Not enough colors given (needed %d, got %d)', length(pie_labels_orig), length(p.Results.colors));
  end
  
  patches = findobj(h, 'type', 'patch');
  for kk = 1:length(patches)
    if iscell(colors)
      this_color = colors{kk};
    else
      this_color = colors(kk,:);
    end
    
    set(patches(kk), 'facecolor', this_color);
  end
end

1;