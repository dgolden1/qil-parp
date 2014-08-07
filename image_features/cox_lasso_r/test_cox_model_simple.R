# Do some Cox model stuff on Diehn Lung distant failure data
# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: test_cox_model_simple.R 317 2013-06-29 21:01:00Z dgolden $

# Setup
library(survival)

# Load data
failure_name = "Distant Failure"
months = c(29, 5, 8, 6, 6, 3, 8, 22, 25, 23, 8, 6, 25, 32, 27, 3, 4, 24, 36, 38, 14, 8, 13, 22, 36, 20, 17, 28, 46, 13, 14, 7, 4, 12, 18, 24, 12, 24, 45, 39, 22, 34, 18, 17, 23, 74, 16, 66, 17, 23, 5, 3, 16, 17, 31, 7, 6, 11, 31, 62, 4, 42, 43, 9, 19, 22, 9)
b_censored = c(1, 0, 1, 1, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0) == 1
volume = c(2112.39, 11718.3, 3096.31, 40233.1, 2797.69, 26620.6, 14281.3, 3631.11, 53617.9, 13732.9, 15981.7, 2936.79, 1957.41, 9524.81, 5868.19, 11479.8, 10120.9, 5956.88, 14541.1, 6361, 10533.3, 26493, 6580.35, 2411.6, 34325.1, 2681.01, 51074, 6352.66, 9429.45, 6797.31, 9607.07, 80246.8, 3623.96, 11210.4, 20141.6, 18792.1, 7493.49, 1453.16, 17893.3, 12706.5, 340.877, 6806.84, 25137.6, 47376.1, 6177.72, 5195.14, 5991.45, 6773.46, 6909.36, 3464.22, 3061.29, 4667.04, 8540.14, 3496.87, 4886.38, 2950.43, 1571.18, 33797, 5626.67, 9881.25, 34607.6, 12750.6, 16448.5, 12506.2, 21319.4, 2830.03, 18329.6)

surv_distant = Surv(months, event=!b_censored, type='right')

# Plot Kaplan-Meier Curve
survfit_result = survfit(surv_distant ~ 1)
print(survfit_result)
plot(survfit_result, xlab="Months", main=sprintf('%s (n=%d)', failure_name, length(b_censored)))

# Save plot
dev.copy(png, "~/temp/r_km_plot.png")
dev.off()

# Make cox model
cox_result = coxph(surv_distant ~ volume)
summary(cox_result)

# Test proportional hazards assumption
cox_zph_result = cox.zph(cox_result)
print(cox_zph_result)
plot(cox_zph_result)