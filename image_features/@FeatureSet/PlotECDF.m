function PlotECDF(obj, varargin)
% Plot empirical CDFs for each definition of response or feature
% 
% PARAMETERS
% output_dir: output_directory (default: '~/temp/feature_ecdfs')
% b_save: save plots or not (default: true)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('output_dir', '~/temp/feature_ecdfs');
p.addParamValue('b_save', true);
p.parse(varargin{:});
output_dir = p.Results.output_dir;

%% Categorical features
if obj.bFeaturesCategorical && ~obj.bResponseCategorical
  figure;
  hold on;
  colors = get(gca, 'colororder');
  for kk = 1:length(obj.FeatureNames)
    [ecdfs{kk}, ecdfs_x{kk}] = ecdf(obj.Response(obj.FeatureVector(:,strcmp(obj.FeatureNames, obj.FeatureNames{kk})) ~= 0));
    stairs(ecdfs_x{kk}, ecdfs{kk}, 'linewidth', 2, 'color', colors(kk,:));
  end

  xlabel(Y_name);
  ylabel('Empirical CDF');
  legend(obj.FeaturePrettyNames, 'location', 'southeast');
  box on;
  grid on
  increase_font;
  
%% Categorical response
elseif ~obj.bFeaturesCategorical && obj.bResponseCategorical
  % Make a empirical CDFsfor each feature representing feature
  % values for each response category
  
  if ~exist(output_dir, 'dir')
    mkdir(output_dir);
  end
  
  Y_unique = unique(obj.Response);
  Y_cat_true = Y_unique{1};
  Y_cat_false = Y_unique{2};

  figure;
  for kk = 1:length(obj.FeatureNames)
    t_start = now;

    if p.Results.b_save
      clf;
    elseif kk > 1
      figure;
    end
    
    [ftrue, xtrue] = ecdf(obj.FeatureVector(strcmp(obj.Response, Y_cat_true), kk));
    [ffalse, xfalse] = ecdf(obj.FeatureVector(~strcmp(obj.Response, Y_cat_true), kk));
    
    % plot(xtrue, ftrue, 'b', xfalse, ffalse, 'r', 'linewidth', 2);
    stairs(xtrue, ftrue, 'b', 'linewidth', 2);
    hold on;
    stairs(xfalse, ffalse, 'r', 'linewidth', 2);
    grid on;
    
    xlabel(sprintf('%s (feat %d)', obj.FeaturePrettyNames{kk}, kk));
    ylabel('Empirical CDF');
    legend(Y_cat_true, Y_cat_false, 'Location', 'SouthEast');
    increase_font;

    if p.Results.b_save
      output_filename = fullfile(output_dir, sprintf('feature_%03d', kk));
      print_trim_png(output_filename);
      fprintf('Wrote %s (%d of %d) in %s\n', output_filename, kk, length(obj.FeatureNames), time_elapsed(t_start, now));
    end
  end
end
