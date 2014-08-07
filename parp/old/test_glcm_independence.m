% Test independence of GLCM features

close all;
clear;

imsize = 64;

se = strel('disk', 3);
numtrials = 100;

for kk = 1:numtrials
  t_start = now;
  
  rand_img = rand(10, imsize);
  img = imfilter(rand_img, double(se.getnhood), 'circular');

  glcm = graycomatrix(img, 'symmetric', true, 'GrayLimits', []);
  glcm_props(kk) = GLCM_Features1(glcm);
  
  fprintf('Processed image %d of %d in %s\n', kk, numtrials, time_elapsed(t_start, now));
end

fn = fieldnames(glcm_props);
props_matrix = zeros(numtrials, length(fn));
for kk = 1:length(fn)
  props_matrix(:, kk) = [glcm_props.(fn{kk})].';
end

[coeff, score, latent] = princomp(zscore(props_matrix));

variance_fraction = cumsum(latent)/sum(latent);

for kk = 1:length(variance_fraction)
  fprintf('%02d components: %0.4f variance\n', kk, variance_fraction(kk));
end
