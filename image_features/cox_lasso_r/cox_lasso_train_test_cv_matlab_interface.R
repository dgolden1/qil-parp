# Interface for running run_cox_lasso() in cox_lasso_fcn.R from Matlab
# Trains on one data set and tests on another
# Cross-validation is performed in R

# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: cox_lasso_train_test_cv_matlab_interface.R 347 2013-07-17 00:05:49Z dgolden $

# Setup
graphics.off() # Close open figures
rm(list = ls()) # Clear workspace
t_start = proc.time()[3]

source('/Users/dgolden/software/image_features/cox_lasso_r/cox_lasso_fcn.R')
library(R.matlab)

output_filename = '/tmp/data_from_r.mat'
source('/tmp/data_from_matlab.R') # Variables should be: x, y, b_censored, alpha, ncvfolds, b_net_model

set.seed(0) # Make results reproducible while I'm debugging this procedure
warning('DEBUG: Random number generator seeded at 0')

# Run outer cross-validation loop
cox_results = run_cox_lasso_outer_cv(x=x, y=y, b_censored=b_censored, alpha=alpha, nfolds.inner=ncvfolds, nfolds.outer=ncvfolds)

# Evaluate predictors via another Cox PH run
surv_obj = Surv(time=y, event=!b_censored, type='right')
cox_eval_summary = summary(coxph(surv_obj ~ cox_results$linear_predictors, x=TRUE))

# Evaluate predictors via log-rank test, stratified by
# sextile <=3 and sextile > 3 (cross-validated median)
# sextile <=2 and sextile > 4 (cross-validated upper and lower third)
# Formula for p-value from https://stat.ethz.ch/pipermail/r-help/2007-April/130676.html
if (any(cox_results$sextiles <= 3) && any(cox_results$sextiles > 3)) {
  log_rank_strata_median_results = survdiff(surv_obj ~ cox_results$sextiles <= 3)
  log_rank_strata_median_p = 1 - pchisq(log_rank_strata_median_results$chisq, length(log_rank_strata_median_results$n) - 1)
} else {
  log_rank_strata_median_p = NaN
}
if (any(cox_results$sextiles <= 2) && any(cox_results$sextiles > 4)) {
  log_rank_strata_third_results = survdiff(surv_obj ~ cox_results$sextiles <= 2, subset=cox_results$sextiles %in% c(1,2,5,6))
  log_rank_strata_third_p = 1 - pchisq(log_rank_strata_third_results$chisq, length(log_rank_strata_third_results$n) - 1)
} else {
  log_rank_strata_third_p = NaN
}

# Also run a net model without an outer cross-validation loop
if (b_net_model) {
  glmnet_res = run_cox_lasso(x=x, event_times=as.numeric(y), b_censored=as.logical(b_censored), alpha=alpha, nfolds=ncvfolds, b_make_plots=FALSE, b_save_plots=FALSE)
  net_model_output = list(lambda=glmnet_res$lambda,
                          cvm=glmnet_res$cvm,
                          cvsd=glmnet_res$cvsd,
                          cvup=glmnet_res$cvup,
                          cvlo=glmnet_res$cvlo,
                          nzero=glmnet_res$nzero,
                          name=glmnet_res$name,
                          lambda_min=glmnet_res$lambda.min,
                          lambda_1se=glmnet_res$lambda.1se,
                          beta=glmnet_res$glmnet.fit$beta)
} else {
  net_model_output=NULL
}

elapsed_time = proc.time()[3] - t_start

# Save output
writeMat(output_filename,
         b_null_model=as.numeric(cox_results$b_null_model),
         linear_predictors=cox_results$linear_predictors,
         sextiles=cox_results$sextiles,
         cox_coef=cox_eval_summary$coefficients,
         cox_coef_names=colnames(cox_eval_summary$coefficients),
         log_rank_strata_median_p=log_rank_strata_median_p,
         log_rank_strata_third_p=log_rank_strata_third_p,
         net_model_output=net_model_output,
         elapsed_time=elapsed_time)
print(paste('Wrote', output_filename))