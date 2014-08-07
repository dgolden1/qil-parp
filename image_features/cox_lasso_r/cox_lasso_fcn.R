# Functions related to running Cox proportional hazards lasso/elastic net regression

# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: cox_lasso_fcn.R 347 2013-07-17 00:05:49Z dgolden $

## Setup
library(glmnet)
library(survival)
library(cvTools)


## FUNCTION: Fake some input data
make_fake_data = function(num_patients=50, num_features=5, num_real_features=3){
  set.seed(0) # Make reproducible random values
  warning('Random number generator seeded at 0 in make_fake_data()')
  
  feature_names = paste("feature", 1:num_features)
  patient_names = paste("patient", 1:num_patients)
  
  x = matrix(runif(num_patients*num_features, min=0, max=20/num_real_features), num_patients, num_features, dimnames = list(patient_names, feature_names))
  event_times = apply(x[,1:(num_real_features)], 1, sum) + runif(num_patients, min=0, max=5)
  
  # Randomly censor some values
  b_censored = sample(0:1, length(event_times), replace = TRUE)
  
  # Randomly subtract up to 5 months from the censored data set; ensure that the time values are still at least 1
  event_times[b_censored] = pmax(event_times[b_censored] - runif(sum(b_censored), 1, 5), 1)
  
  df = data.frame(x)
  
  b_save_plots = FALSE
  
  return(list(df=df, event_times=event_times, b_censored=b_censored, b_save_plots=b_save_plots))
}


## FUNCTION: run Cox PH lasso regression
run_cox_lasso = function(x, event_times, b_censored, alpha=1, nfolds=10, b_make_plots=FALSE, b_save_plots=FALSE) {
  ## Plot Kaplan-Meier survival curve
  surv_obj = Surv(time=event_times, event=!b_censored, type='right')
  
  ## Run Lasso model
  glmnet_res = cv.glmnet(as.matrix(x), y=surv_obj, family= 'cox', alpha=alpha, nfolds=nfolds)
#   glmnet_res = tryCatch(cv.glmnet(as.matrix(x), y=surv_obj, family= 'cox', alpha=alpha, nfolds=nfolds), error = function(e) e)
#   if (class(glmnet_res)[1] == 'simpleError') {
#     throw(glmnet_res)
#   }
  
  if (b_make_plots) {
    plot(survfit(surv_obj ~ 1), xlab='Months')
    if (b_save_plots) {
      dev.copy(png, "~/temp/r_km_plot.png")
      dev.off()
    }
    plot(glmnet_res)
    if (b_save_plots) {
      dev.copy(png, '~/temp/r_lasso_cv_plot.png')
      dev.off()
    }
  }
  
  return(glmnet_res)
}

## Function handle certain kinds of glmnet errors
handle_glmnet_error = function(e) {
  browser()
}

## FUNCTION run Cox PH model with lasso regularization and save linear_predictors
run_cox_lasso_outer_cv = function(x, y, b_censored, alpha=1, nfolds.outer=10, nfolds.inner=10) {
  
  # Generate cross-validation partitions
  #cvp = cvFolds(length(y), K=nfolds.outer)
  
  # Generate cross-validation partitions stratified by censoring
  cvp = cv_with_strata(length(y), nfolds=nfolds.outer, strata=b_censored, balance_by='strata')
  
  # Loop over folds
  linear_predictors = numeric(length(y))*NaN
  sextiles = numeric(length(y))*NaN
  b_null_model = logical(length(y))
  for (kk in 1:nfolds.outer) {
    t_start = proc.time()[3]
    
    idx_train = cvp$subsets[cvp$which != kk]
    idx_test = cvp$subsets[cvp$which == kk]
    x_train = x[idx_train,]
    y_train = y[idx_train]
    b_censored_train = b_censored[idx_train]
    x_test = x[idx_test,]
    y_test = y[idx_test]
    b_censored_test = b_censored[idx_test]
    
    # Train model
    glmnet_res = run_cox_lasso(x=x_train, event_times=as.numeric(y_train), b_censored=as.logical(b_censored_train), 
                               nfolds=nfolds.inner, alpha=alpha, b_make_plots=FALSE)
    
    # Get linear predictors for "test" set
    linear_predictors[idx_test] = predict(glmnet_res, matrix(x_test, nrow=length(idx_test)))
    
    # Determine which sextile (sixth) of the training set's predicted values these test set
    # predicted values fall into
    linear_predictors_train_set = predict(glmnet_res, matrix(x_train, nrow=length(idx_train)))
    sextile_edges = quantile(linear_predictors_train_set, seq(0, 1, length.out=7))
    sextile_edges[c(1, length(sextile_edges))] = c(-Inf, Inf)
    
    # Roundoff error sometimes makes sextile_edges that should be the same slightly different;
    # make them the same
    sextile_edges[c(FALSE, diff(sextile_edges) < 0)] = sextile_edges[c(diff(sextile_edges) < 0, FALSE)]
    
    sextiles[idx_test] = findInterval(linear_predictors[idx_test], vec=sextile_edges)
    
    # Gather some statistics
    b_null_model[idx_test] = glmnet_res$lambda.1se == max(glmnet_res$lambda)
    
    print(sprintf('Processed fold %d of %d in %0.3f sec', kk, nfolds.outer, proc.time()[3] - t_start))
  }
  
  return(list(linear_predictors=linear_predictors, sextiles=sextiles, b_null_model=b_null_model))
}

## FUNCTION: make cross-validation folds with stratification
# strata is boolean vector of the same length as vals specifying classes
# over which to stratify
cv_with_strata = function(n, nfolds, strata, balance_by='strata') {
  
  vals = 1:n
  
  # Separately get cross-validation folds for positive and negative group
  # Groups may have fewer values than nfolds, in which case, use leave-one-out
  # Cross-validation for that group
  vals_pos = vals[as.logical(strata)]
  cvp_pos = cvFolds(length(vals_pos), K=min(nfolds, length(vals_pos)))
  cvp_pos$subsets = as.matrix(vals_pos[cvp_pos$subsets])
  vals_neg = vals[!as.logical(strata)]
  cvp_neg = cvFolds(length(vals_neg), K=min(nfolds, length(vals_neg)))
  cvp_neg$subsets = as.matrix(vals_neg[cvp_neg$subsets])
  
  # Concatenate together
  cvp = cvp_pos
  cvp$n = cvp_pos$n + cvp_neg$n
  cvp$subsets = rbind(cvp_pos$subsets, cvp_neg$subsets)
  
  if (balance_by == 'strata')
    cvp$which = c(cvp_pos$which, cvp_neg$which) # Total number per fold less balanced
  else if (balance_by == 'num')
    cvp$which = c(cvp_pos$which, nfolds - cvp_neg$which + 1) # Stratification less balanced
  else
    stop(paste('Invalid entry for balance_by:', balance_by))
  
  return(cvp)
}

## FUNCTION: fixes a bug in glmnet function with the same name
jerr.coxnet.dgolden = function (n, maxit, pmax) 
{
  if (n > 0) {
    outlist = jerr.elnet(n)
    if (outlist$msg != "Unknown error") 
      return(outlist)
    if (n == 8888) 
      msg = "All observations censored - cannot proceed"
    else if (n == 9999) 
      msg = "No positive observation weights"
    else if (match(n, c(20000, 30000), FALSE)) 
      msg = "Inititialization numerical error"
    else msg = "Unknown error"
    list(n = n, fatal = TRUE, msg = msg)
  } else if (n < 0) {
    if (n <= -30000) {
      msg = paste("Numerical error at ", -n - 30000, "th lambda value; solutions for larger values of lambda returned", 
                  sep = "")
      list(n = n, fatal = FALSE, msg = msg)
    }
    else jerr.elnet(n, maxit, pmax)
  }
}
assignInNamespace('jerr.coxnet', jerr.coxnet.dgolden, 'glmnet')
