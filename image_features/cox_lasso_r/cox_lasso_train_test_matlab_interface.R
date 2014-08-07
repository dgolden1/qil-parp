# Interface for running run_cox_lasso() in cox_lasso_fcn.R from Matlab
# Trains on one data set and tests on another

# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: cox_lasso_train_test_matlab_interface.R 321 2013-07-03 00:29:12Z dgolden $

# Setup
graphics.off() # Close open figures
rm(list = ls()) # Clear workspace

source('/Users/dgolden/software/image_features/cox_lasso_r/cox_lasso_fcn.R')
library(R.matlab)

output_filename = '/tmp/data_from_r.mat'

# Run Cox PH cv.glmnet function on training set
t_start = proc.time()[3]
source('/tmp/data_from_matlab.R')
glmnet_res = run_cox_lasso(x=x_train, event_times=as.numeric(y_train), b_censored=as.logical(b_censored_train), alpha=alpha, b_make_plots=FALSE)

# Predict test set
linear_predictors = predict(glmnet_res, as.matrix(x_test))

elapsed_time = proc.time()[3] - t_start

# Save output
writeMat(output_filename,
         lambda=glmnet_res$lambda, 
         cvm=glmnet_res$cvm,
         cvsd=glmnet_res$cvsd,
         cvup=glmnet_res$cvup,
         cvlo=glmnet_res$cvlo,
         nzero=glmnet_res$nzero,
         beta=as.matrix(glmnet_res$glmnet.fit$beta),
         lambda_min=glmnet_res$lambda.min,
         lambda_1se=glmnet_res$lambda.1se,
         name=glmnet_res$name,
         linear_predictors=linear_predictors,
         elapsed_time=elapsed_time)
print(paste('Wrote', output_filename))