# Script to run a Cox proportional hazards elastic net model for a given value of alpha
# This script is meant to be called by the Matlab method FeatureSet.RunCoxElasticNet

# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: test_cox_lasso_fcn.R 327 2013-07-04 23:32:14Z dgolden $

## Setup
graphics.off() # Close open figures
rm(list = ls()) # Clear workspace

library('glmnet')
library('survival')

source('/Users/dgolden/software/image_features/cox_lasso_r/cox_lasso_fcn.R')

## Get data
# Fake for now; later, get from Matlab
alpha = 1 # Hard code this for now; later, read it from Matlab
fake_data = make_fake_data(num_patients=50, num_features=10, num_real_features=2)
df = fake_data$df
event_times = fake_data$event_times
b_censored = fake_data$b_censored
b_save_plots = fake_data$b_save_plots

## Plot Kaplan-Meier survival curve
surv_obj = Surv(time=event_times, event=!b_censored, type='right')
plot(survfit(surv_obj ~ 1), xlab='Months')
if (b_save_plots) {
  dev.copy(png, "~/temp/r_km_plot.png")
  dev.off()
}

## Run standard Cox PH regression
if (ncol(df) < nrow(df)) {
  cox_result = coxph(surv_obj ~ ., data=df, x=TRUE)
  print(summary(cox_result))
}

## Run NON-CROSS-VALIDATED glmnet Cox PH elastic net regression
glmnet_res_nocv = glmnet(as.matrix(df), surv_obj, family = 'cox', alpha = alpha)
plot(glmnet_res_nocv, 'lambda')

## Run CROSS-VALIDATED glmnet Cox PH elastic net regression
glmnet_res = cv.glmnet(as.matrix(df), surv_obj, family = 'cox', alpha = alpha, nfolds = 10)
plot(glmnet_res)
if (b_save_plots) {
  dev.copy(png, '~/temp/r_lasso_cv_plot.png')
  dev.off()
}

## Run cross-validated glmnet Cox PH with an additional outer cross-validation loop
nfolds.outer = 10
nfolds.inner = 10
# nfolds.outer = length(event_times)
# nfolds.inner = length(event_times)

glmnet_outer_cv_res = run_cox_lasso_outer_cv(x=as.matrix(df), y=event_times, b_censored=b_censored, alpha=alpha, 
                                             nfolds.outer=nfolds.outer, nfolds.inner=nfolds.inner)
linear_predictors = glmnet_outer_cv_res$linear_predictors
cox_outer_cv_result = coxph(surv_obj ~ linear_predictors, x=TRUE)
print(summary(cox_outer_cv_result))

# Generate survival curves for patients above and below the median of linear_predictors
idx_below_median = linear_predictors < median(linear_predictors)
plot(survfit(surv_obj ~ 1 + strata(idx_below_median)), conf.int=TRUE, col=c('red','blue'), xlab='months')
grid()
# s1 = Surv(time=event_times[idx_below_median], event=!b_censored[idx_below_median], type='right')
# plot(survfit(s1 ~ 1), col='red', xlim=c(0,20), ylim=c(0,1))
# par(new=T)
# s2 = Surv(time=event_times[!idx_below_median], event=!b_censored[!idx_below_median], type='right')
# plot(survfit(s2 ~ 1), col='blue', xlim=c(0,20), ylim=c(0,1))
# par(new=F)