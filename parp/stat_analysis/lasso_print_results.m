function lasso_print_results(b, fitinfo, X, X_names, Y_name, mcreps, lasso_type_str, min_error, min_plus_1SE_error, null_error, roc, optimal_pt, t_lasso_start)
% Print results of lasso to terminal

% By Daniel Golden (dgolden1 at stanford dot edu) August 2012
% $Id$

if exist('t_lasso_start', 'var') && ~isempty(t_lasso_start)
  time_str = sprintf(' in %s', time_elapsed(t_lasso_start, now));
else
  time_str = '';
end

chosen_b = b(:, fitinfo.Index1SE);
if all(chosen_b == 0)
  fprintf('%s for %s chose no features%s (%d MC reps), min error=%G, null model error=%G\n', ...
    lasso_type_str, Y_name, time_str, mcreps, min_error, null_error);
else
  fprintf('%s for %s chose %d features%s (%d MC reps), min error=%G, min+1SE error=%G, null model error=%G', ...
    lasso_type_str, Y_name, sum(chosen_b ~= 0), time_str, mcreps, min_error, min_plus_1SE_error, null_error);
  
  if ~isempty(roc)
    fprintf(', AUC = %0.2f+/-%0.2f, Sens=%0.2f+/-%0.2f, Spec=%0.2f+/-%0.2f', mean(roc.AUC), std(roc.AUC), ...
      mean(optimal_pt.sensitivity), std(optimal_pt.sensitivity), mean(optimal_pt.specificity), std(optimal_pt.specificity))
  end
  fprintf('\n');
  
  chosen_b_idx = find(chosen_b ~= 0);
  for kk = 1:length(chosen_b_idx)
    fprintf('Feature %d %s: %g (b*std = %g)\n', chosen_b_idx(kk), X_names{chosen_b_idx(kk)}, chosen_b(chosen_b_idx(kk)), ...
      chosen_b(chosen_b_idx(kk))*std(X(:, chosen_b_idx(kk))));
  end
end
