function feature_set = GetFeatureHist(obj)
% Get histogram features from an image
% feature_set = get_histogram_features(values)
% 
% Similar to histogram-based features from Tixier et al. 2011 (doi:
% 10.2967/jnumed.110.082404)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id: GetFeatureHist.m 300 2013-06-13 21:10:56Z dgolden $

hist_struct.patient_id = obj.PatientID;

if isempty(obj.MyROI)
  values = nan;
else
  values = obj.ROIPixels;
end

hist_struct.mean = nanmean(values);
hist_struct.var = nanvar(values);
hist_struct.skewness = skewness(values);
hist_struct.kurtosis = kurtosis(values);
%hist_struct.std = nanstd(values);
%hist_struct.q25 = quantile(values, 0.25);
%hist_struct.q75 = quantile(values, 0.75);

feature_pretty_names = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};

if isempty(obj.ImageName)
  feature_category_name = 'hist';
else
  feature_category_name = ['hist_' obj.ImageName];
end
if isempty(obj.ImagePrettyName)
  feature_category_pretty_name = 'Histogram';
else
  feature_category_pretty_name = ['Histogram ' obj.ImagePrettyName];
end
feature_set = FeatureSet(hist_struct, feature_pretty_names, feature_category_name, feature_category_pretty_name);
