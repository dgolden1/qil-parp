# Do some Cox model stuff on Diehn Lung distant failure data
# By Daniel Golden (dgolden1 at stanford dot edu) June 2013
# $Id: test_cox_model.R 317 2013-06-29 21:01:00Z dgolden $

# Setup
library(survival)
graphics.off() # Close open figures
rm(list = ls()) # Clear workspace

# Load data
# This file was generated with the following Matlab command:
# ldb.ExportToCSV('~/temp/features.csv', 'feature_args', {'b_volume', true, 'b_histogram', true, 'b_glcm_2d', true, 'b_remove_excluded_patients', false, 'b_glcm_2d_multi_slice', true}, 'b_excluded_col', true);
input_filename = "/Users/dgolden/temp/features.csv"
feature_set_full = read.csv(input_filename, row.names=1)

# Exclude patients
feature_set_full = feature_set_full[!feature_set_full$excluded,]

# Separate data into features and outcomes
response_names = c("local", "regional", "distant", "local_months", "regional_months", "distant_months")
b_excluded = feature_set_full[["excluded"]] == 1
feature_set = feature_set_full[,!(names(feature_set_full) %in% c(response_names, "excluded"))]
responses = feature_set_full[,names(feature_set_full) %in% response_names]

# Choose a specific type of response
failure_name = "Distant"
surv_object = Surv(responses$distant_months, event=responses$distant, type='right')

# Plot Kaplan-Meier Curve
survfit_result = survfit(surv_object ~ 1)
print(survfit_result)
plot(survfit_result, xlab="Months", main=sprintf('%s (n=%d)', failure_name, nrow(feature_set)))

# Save plot
#dev.copy(png, "~/temp/r_km_plot.png")
#dev.off()

# Make cox model for all features simultaneously
# cox_result = coxph(surv_object ~ ., data=feature_set, x=TRUE)
# print(summary(cox_result))

# Test proportional hazards assumption
# cox_zph_result = cox.zph(cox_result)
# print(cox_zph_result)
#plot(cox_zph_result)

# Make cox model and assemble p-values for each predictor
numel = ncol(feature_set)
# numel = 5
p = numeric(numel)
p_zph = numeric(numel)
feature_names = character(numel)
for (kk in 1:numel) {
  this_feature = feature_set[kk]
  cox_result = coxph(surv_object ~ ., data=this_feature, x=TRUE)
  #print(summary(cox_result))
  p[kk] = summary(cox_result)$coefficients[,"Pr(>|z|)"]
  
  cox_zph_result = cox.zph(cox_result)
  #print(cox_zph_result)
  p_zph[kk] = cox_zph_result$table[,"p"]
  
  feature_names[kk] = names(feature_set)[kk]
}

# Assemble data frame
p_value_data_frame = data.frame(p=p, p_zph=p_zph, row.names=feature_names)

# Write output file
output_filename = sub(".csv", "_cox_output.csv", input_filename)
write.csv(p_value_data_frame, output_filename)
print(sprintf("Wrote output to %s", output_filename))