function PrintOutput(obj)
% Print Lasso output

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

time_str = sprintf(' in %s', time_elapsed(0, obj.ElapsedSeconds/86400));

chosen_b = obj.b(:, obj.fitinfo.Index1SE);
if all(chosen_b == 0)
  % Chose no features
  fprintf('%s lasso for %s chose no features%s (%d MC reps), min error=%G, null model error=%G\n', ...
    obj.Type, obj.YName, time_str, obj.mcreps, obj.MinError, obj.NullError);
else
  % Chose some features
  fprintf('%s lasso for %s chose %d features%s (%d MC reps), min error=%G, min+1SE error=%G, null model error=%G', ...
    obj.Type, obj.YName, sum(chosen_b ~= 0), time_str, obj.mcreps, obj.MinError, obj.MinPlus1SEError, obj.NullError);
  
  if ~isempty(obj.ROC)
    fprintf(', AUC = %0.2f+/-%0.2f, Sens=%0.2f+/-%0.2f, Spec=%0.2f+/-%0.2f', mean(obj.ROC.AUC), std(obj.ROC.AUC), ...
      mean(obj.ROC.opt_sensitivity), std(obj.ROC.opt_sensitivity), mean(obj.ROC.opt_specificity), std(obj.ROC.opt_specificity))
  end
  fprintf('\n');
  
  chosen_b_idx = find(chosen_b ~= 0);
  for kk = 1:length(chosen_b_idx)
    fprintf('Feature %d %s: %g (b*std = %g)\n', chosen_b_idx(kk), obj.ThisFeatureSet.FeatureNames{chosen_b_idx(kk)}, chosen_b(chosen_b_idx(kk)), ...
      chosen_b(chosen_b_idx(kk))*std(obj.ThisFeatureSet.FeatureVector(:, chosen_b_idx(kk))));
  end
end

% Print some additional information for the cox model
if strcmp(obj.Type, 'cox')
  pvals = cell2mat(obj.fitinfo.pval);
  if length(pvals) == 1
    pval_str = sprintf(': %g', pvals(1));
  else
    pval_str = sprintf(' mean: %g, range: [%g, %g]', mean(pvals), min(pvals), max(pvals));
  end
  
  fprintf('Cross-validated linear predictor Cox PH p-val%s\n', pval_str);
end
