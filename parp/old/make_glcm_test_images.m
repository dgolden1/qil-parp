function make_glcm_test_images(output_dir)
% Make some test images to see what their GLCM properties are

% By Daniel Golden (dgolden1 at stanford dot edu) September 2012
% $Id$

%% Setup
close all;

rng('default'); % Reproducable results
imsize = 64;

if ~exist('output_dir', 'var')
  output_dir = '';
end

%% Make images
images = {};

% Blank image
img = zeros(imsize);
images{end+1} = img;

% Image with a single high point
img = zeros(imsize);
img(imsize/2, imsize/2) = 1;
images{end+1} = img;

% Image with a bunch of scattered points of varying magnitude
img = zeros(imsize);
rand_idx = rand(size(img)) > 0.95;
rand_vals = rand(sum(rand_idx(:)), 1);
img(rand_idx) = rand_vals;
images{end+1} = img;

% Random image
rand_img = rand(imsize);
img = rand_img;
images{end+1} = img;

% Random smoothed image
rand_img = rand(imsize);
se = strel('disk', 3);
img = imfilter(rand_img, double(se.getnhood), 'circular');
images{end+1} = img;

% Random more coarsely smoothed image
rand_img = rand(imsize);
se = strel('disk', 6);
img = imfilter(rand_img, double(se.getnhood), 'circular');
images{end+1} = img;

% Random black and white image
img = double(rand_img > 0.5);
images{end+1} = img;

% Smoothly varying image, increasing from center
x = linspace(-1, 1, imsize);
[X, Y] = meshgrid(x, x);
R = sqrt(X.^2 + Y.^2)/sqrt(2); % Max R = 1
img = R;
images{end+1} = img;

% Center black, outer white
img = double(R > 0.5);
images{end+1} = img;

% Smoothly varying image, sinusoidal, 4 periods
img = cos(4*R*2*pi);
images{end+1} = img;

% Smoothly varying image, sinusoidal, 8 periods
img = cos(8*R*2*pi);
images{end+1} = img;

% Sharply varying image, sinusoidal, 8 periods
img = cos(8*R*2*pi).^2;
images{end+1} = img;

% Smoothly varying image, sinusoidal, 4 periods, black level decreasing
% with increasing radius
img = cos(4*R*2*pi).*(1 - R);
images{end+1} = img;

%% Get GLCM properties for each image
for kk = 1:length(images)
  [glcm_props(kk), glcm{kk}] = get_glcm_properties(images{kk}, [], [0 1]);
end

%% Plot empirical CDFs for each property
% figure;
% co = get(gca, 'colororder');
% hold on;
% 
% fn = fieldnames(glcm_props);
% for kk = 1:length(fn)
%   [ecdfs(kk).f, ecdfs(kk).x] = ecdf([glcm_props.(fn{kk})]);
%   
%   subplot(4, 1, kk);
%   stairs(ecdfs(kk).x, ecdfs(kk).f, 'color', co(kk,:), 'linewidth', 2);
%   grid on;
%   
%   legend(fn{kk}, 'location', 'southeast');
% end
% 
% increase_font;

%% Plot images with empirical CDFs
fn = fieldnames(glcm_props);
for kk = 1:length(fn)
  plot_images_with_cdf(output_dir, images, [glcm_props.(fn{kk})], fn{kk});
  plot_images_by_value(output_dir, images, [glcm_props.(fn{kk})], fn{kk});
end

%% Plot images
% ordering = 1:length(images);
% titles = repmat({''}, 1, length(images));
% fig_title = 'Original Order';
% plot_images(images, ordering, titles, fig_title);


%% Plot by GLCM Correlation
% [~, ordering] = sort([glcm_props.Correlation]);
% titles = cellfun(@num2str, num2cell([glcm_props.Correlation]), 'UniformOutput', false);
% fig_title = 'GLCM Correlation';
% plot_images(images, ordering, titles, fig_title);

%% Plot by GLCM Energy
% [~, ordering] = sort([glcm_props.Energy]);
% titles = cellfun(@num2str, num2cell([glcm_props.Energy]), 'UniformOutput', false);
% fig_title = 'GLCM Energy';
% plot_images(images, ordering, titles, fig_title);

%% Plot by GLCM Homogeneity
% [~, ordering] = sort([glcm_props.Homogeneity]);
% titles = cellfun(@num2str, num2cell([glcm_props.Homogeneity]), 'UniformOutput', false);
% fig_title = 'GLCM Homogeneity';
% plot_images(images, ordering, titles, fig_title);

function plot_images(images, ordering, titles, fig_title)
%% Function: plot images in a specific order

% Super subplot properties
hspace = 0.05;
vspace = 0;
hmargin = 0;
vmargin = [0 0.05];

figure; 

grid_size = ceil(sqrt(length(images)));
for kk = 1:length(images)
  super_subplot(grid_size, grid_size, kk, hspace, vspace, hmargin, vmargin);
  imagesc(images{ordering(kk)});
  title(titles{ordering(kk)});
  axis equal tight off;
end

colormap gray;
figure_grow(gcf, 1, 1.5);
increase_font;

set(gcf, 'Name', fig_title);

function plot_images_with_cdf(output_dir, images, values, value_name)
%% Function: Plot images along with value empirical CDF

% Super subplot properties
hspace = 0.01;
vspace = 0.1;
hmargin = [0.05 0];
vmargin = [0 0.075];
numrows = 3;
numcols = ceil(length(images)/2);

figure; 

% Plot images
values_nonan = values;
values_nonan(isnan(values_nonan)) = 0;
[~, ordering] = sort(values_nonan);

for kk = 1:length(images)
  if kk < length(images)/2
    img_idx = kk;
  else
    img_idx = kk + numcols + 1;
  end
  
  super_subplot(numrows, numcols, img_idx, hspace, vspace, hmargin, vmargin);
  % subplot(2, length(images), length(images) + kk);
  imagesc(images{ordering(kk)});
  title(sprintf('%g', values(ordering(kk))));
  axis equal tight off;
end

% Plot empirical CDF
h = super_subplot(numrows, numcols, (numcols+1):(2*numcols), hspace, vspace, hmargin, vmargin);

% Nudge the axis up a bit
pos = get(h, 'position');
set(h, 'position', [pos(1), pos(2) + 0.075, pos(3:4)]);

% subplot(2, length(images), 1:length(images));
[f, x] = ecdf(values);
stairs(x, f, 'k', 'linewidth', 2);
grid on;
h = xlabel(value_name);
set(h, 'fontweight', 'bold');
ylabel('CDF');

colormap gray;
figure_grow(gcf, 1.5, 1);
increase_font;

if ~isempty(output_dir)
  output_filename = fullfile(output_dir, sprintf('glcm_example_%s', lower(value_name)));
  print('-dpdf', output_filename);
  print('-dpng', output_filename);
  fprintf('Saved %s\n', output_filename);
end

function plot_images_by_value(output_dir, images, values, value_name)
%% Function: Plot images spaced according to their value

values(isnan(values)) = 0;

% Also make a plot with images spaced according to their value
figure
ax_size = [1 1]*0.2;
max_ax_x = 1 - ax_size(1);
for kk = 1:length(images)
  this_img_y = 0.5 - ax_size(2)/2;
  this_img_x = (values(kk) - min(values))/range(values)*max_ax_x;
  this_img_pos = [this_img_x, this_img_y, ax_size];
  
  axes('position', this_img_pos);
  imagesc(images{kk});
  axis equal tight off;
end

colormap gray;
figure_grow(gcf, 1.5, 1);

if ~isempty(output_dir)
  output_filename = fullfile(output_dir, sprintf('glcm_example_spaced_by_value_%s', lower(value_name)));
  print('-dpdf', output_filename);
  print('-dpng', output_filename);
  fprintf('Saved %s\n', output_filename);
end
