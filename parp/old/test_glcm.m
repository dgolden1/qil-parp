function test_glcm
% Get some diagnostics about the GLCM

% By Daniel Golden (dgolden1 at stanford dot edu) March 2012
% $Id$

%% Setup
X = randn([10 10 100]);
grayco_offsets = [0 1; -1 1; -1 0; -1 -1];

%% Get graycomatrix for all images

for kk = 1:size(X, 3)
  this_glcm = graycomatrix(X(:,:,kk), 'Offset', grayco_offsets, 'symmetric', true);
  this_glcm_stats = graycoprops(this_glcm);
  
  % Try to replicate the GLCM propeties manually
  p = this_glcm(:,:,1)/sum(flatten(this_glcm(:,:,1)));
  p_size = size(p, 1);
  [i, j] = ndgrid(1:p_size, 1:p_size);
  mu_i = sum(flatten(i.*p));
  mu_j = sum(flatten(j.*p));
  std_i = sqrt(sum(flatten((i - mu_i).^2.*p)));
  std_j = sqrt(sum(flatten((j - mu_j).^2.*p)));
  
  % p_i = sum(p, 2);
  % p_j = sum(p, 1);
  % my_correlation = sum(flatten((i.*j.*p - mean(p_i)*mean(p_j))./(std(p_i).*std(p_j)))); % Haralick 1973 version

  my_contrast = sum(flatten(abs(i - j).^2.*p));
  my_correlation = sum(flatten((i - mu_i).*(j - mu_j).*p./(std_i.*std_j))); % Matlab version
  my_energy = sum(flatten(p.^2));
  my_homogeneity = sum(flatten(p./(1 + abs(i - j))));
end

1;
