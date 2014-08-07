# Interface for running run_cox_lasso() in cox_lasso_fcn.R from Matlab

# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: cox_lasso_matlab_interface.R 317 2013-06-29 21:01:00Z dgolden $

# Setup
graphics.off() # Close open figures
rm(list = ls()) # Clear workspace

source('/Users/dgolden/software/image_features/cox_lasso_r/cox_lasso_fcn.R')
source('/tmp/data_from_matlab.R')
library(R.matlab)

output_filename = '/tmp/data_from_r.mat'

# Run function
glmnet_res = run_cox_lasso(x=x, event_times=as.numeric(event_times), b_censored=as.logical(b_censored), alpha=alpha, b_save_plots=b_save_plots)

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
         name=glmnet_res$name)
print(paste('Wrote', output_filename))