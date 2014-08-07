function PlotKSMatrix(obj)
% Function: make Kolmogorov-Smirnov matrix

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

if ~(obj.bFeaturesCategorical && ~obj.bResponseCategorical)
  error('Only defined for categorical features and continuous response');
end

b_two_sided = true; % One sided or two-sided kstest

category = dummy_to_label(obj.FeatureVector, obj.FeatureNames);
categories = obj.FeatureNames;

h_kstest = nan(length(categories)); % True if the null hypothesis is rejected at 5% significane
p_kstest = nan(length(categories)); % p-value

if b_two_sided
  % Alternate hypothesis: Y_1 ~= Y_2
  % Null hypothesis: Y_1 == Y_2
  kstest_type = 'unqeual';
  plot_title = sprintf('Red if null hypothesis (%s_{left} ~= %s_{bottom}) is rejected @ 5%%', obj.ResponseName, obj.ResponseName);
else
  % Alternate hypothesis: Y_1 > Y_2
  % Null hypothesis: Y_1 <= Y_2
  kstest_type = 'larger';
  plot_title = sprintf('Red if null hypothesis (%s_{left} <= %s_{bottom}) is rejected @ 5%%', obj.ResponseName, obj.ResponseName);
end

for jj = 1:length(categories)
  for kk = 1:length(categories)
    if b_two_sided && kk >= jj
      continue;
    end
    
    category_1 = categories{jj};
    category_2 = categories{kk};
    
    Y_1 = obj.Response(strcmp(category, category_1));
    Y_1 = Y_1(isfinite(Y_1));
    Y_2 = obj.Response(strcmp(category, category_2));
    Y_2 = Y_2(isfinite(Y_2));
    
    idx = sub2ind(size(h_kstest), jj, kk);
    
    % According to the Matlab documentation, the kstest is not valid if
    % this is not true
    if length(Y_1)*length(Y_2)/(length(Y_1) + length(Y_2)) >= 4
      [h_kstest(idx), p_kstest(idx)] = kstest2(Y_1, Y_2, 0.05, kstest_type);
    end
  end
end

figure;
[new_image_data, new_color_map, new_cax] = colormap_white_bg(h_kstest, jet, [0 1]);
imagesc(new_image_data);
colormap(new_color_map);
caxis(new_cax);
for kk = 1:length(categories)
  ylabels{kk} = sprintf('%s %d', categories{kk}, kk);
end
set(gca, 'ytick', 1:length(categories), 'yticklabel', ylabels, 'xtick', 1:length(categories));
title(plot_title);
increase_font;
