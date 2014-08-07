function test_princomp
% Run some tests to see if the triple negative data could be simplified
% using principal component analysis

% By Daniel Golden (dgolden1 at stanford dot edu) May 2012
% $Id$

%% Setup
if ~exist('b_stanford_only', 'var') || isempty(b_stanford_only)
  b_stanford_only = false;
end
if ~exist('max_num_features', 'var') || isempty(max_num_features)
  max_num_features = Inf;
end

load('lesion_parameters.mat', 'lesions');

%% Remove outliers
lesions = exclude_patients(lesions, b_stanford_only);

%% Set up input and output matrices
[x, x_names, y, patient_ids] = get_glcm_model_inputs(lesions);

%% Do principal component analysis
[coeff, score, latent] = princomp(zscore(x));

for kk = 1:10
  fprintf('Variance explained by %d PCs: %0.3f, PC %d only: %0.3f\n', kk, sum(latent(1:kk))/sum(latent), kk, latent(kk)/sum(latent));
end

figure;
barh(abs(coeff(:, 1)));
set(gca, 'ytick', 1:length(x_names), 'yticklabel', x_names);
xlabel('PC weight');
axis tight;


1;
