function feature_set = GetFeatureHist(obj, varargin)
% Get histogram features
% feature_set = GetFeatureHist(obj, 'param', value, ...)
% 
% PARAMETERS
% b_tighten_roi: tighten ROI for lung CT (default: false)
% 
% Similar to histogram-based features from Tixier et al. 2011 (doi:
% 10.2967/jnumed.110.082404)
% 
% Basically the same as ImageFeature.GetFeatureHist

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_tighten_roi', false);
p.parse(varargin{:});

%% Extract features
hist_struct.patient_id = obj.PatientID;

if isempty(obj.MyROI3D)
  values = nan;
else
  values = GetROIPixels(obj, 'b_tighten_roi', p.Results.b_tighten_roi);
end

hist_struct.mean = nanmean(values);
hist_struct.var = nanvar(values);
hist_struct.skewness = skewness(values);
hist_struct.kurtosis = kurtosis(values);
% hist_struct.std = nanstd(values); % std is sqrt of variance
%hist_struct.q25 = quantile(values, 0.25);
%hist_struct.q75 = quantile(values, 0.75);

feature_pretty_names = {'Mean', 'Variance', 'Skewness', 'Kurtosis'};

% feature_set = FeatureSet(hist_struct, feature_pretty_names, ['hist_' obj.ImageName], ['Histogram ' obj.ImagePrettyName]);
feature_set = FeatureSet(hist_struct, feature_pretty_names, 'hist', 'Histogram');
