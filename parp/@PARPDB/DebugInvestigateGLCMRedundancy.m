function DebugInvestigateGLCMRedundancy(obj)
% Investigate the redundancy of the full set of GLCM features

% By Daniel Golden (dgolden1 at stanford dot edu) March 2013
% $Id$

feature_categories = {'auc', 'wash_in', 'wash_out', 'ktrans', 'kep', 've'};
matlab_features = {'contrast', 'correlation', 'energy', 'inverse_difference_moment', 'average'};

fs = CollectFeatures(obj, 'b_glcm_full', true);

for kk = 1:length(feature_categories)
  this_fs = RemoveFeatures(fs, fs.FeatureNames(cellfun(@isempty, regexp(fs.FeatureNames, ['_' feature_categories{kk} '_']))));
  
  matlab_feature_names = this_fs.FeatureNames(cellfun(@(x) ~isempty(regexp(fs.FeatureNames, x, 'once')), matlab_features));
  

  error('Go one-by-one and see if non-matlab features add anything to principal component analysis');
  
  [coeff, score, latent] = princomp(zscore(this_fs.FeatureVector));

  variance_fraction = cumsum(latent)/sum(latent);

  fprintf('%s\n', feature_categories{kk});
  
  for kk = 1:8
    fprintf('%02d components: %0.4f variance\n', kk, variance_fraction(kk));
  end
  
  fprintf('\n');
end
