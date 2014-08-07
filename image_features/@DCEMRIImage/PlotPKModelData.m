function PlotPKModelData(obj, b_model_each_pixel)
% Plot data about the PK models

% By Daniel Golden (dgolden1 at stanford dot edu) September 2011
% $Id$

%% Setup
if ~exist('b_model_each_pixel', 'var') || isempty(b_model_each_pixel)
  b_model_each_pixel = false;
end

ktrans = obj.IFKtrans.ROIPixels;
kep = obj.IFKep.ROIPixels;
ve = obj.IFVe.ROIPixels;

%% Get model for each pixel
if b_model_each_pixel
  % Plot each voxel and model
  output_dir = '~/temp/enhancement';
  if ~exist(output_dir, 'dir')
    mkdir(output_dir);
  end

  for kk = 1:length(obj.PKModel)
    t_start = now;

    sfigure(1);
    clf
    plot(obj.PKModel(kk).t_data, obj.PKModel(kk).enhancement_data, 'rs-', obj.PKModel(kk).t_fit, obj.PKModel(kk).enhancement_fit, 'b-');
    grid on;
    legend('Data', 'Fit');
    xlabel('Time (min)');
    ylabel('Enhancement');
    title(sprintf('K_{trans} = %0.2G, k_{ep} = %0.2G, v_e = %0.1f', ktrans(kk), kep(kk), ve(kk)));
    increase_font;

    output_filename = sprintf('~/temp/enhancement/voxel%05d', kk);
    print_trim_png(output_filename);
    fprintf('Saved %s (%d of %d) in %s\n', output_filename, kk, length(obj.PKModel), time_elapsed(t_start, now));
  end
end

% Plot quantiles
quantiles = [0.1 0.5 0.9];
figure;
h = plot(obj.PKModel(1).t_data, quantile(cell2mat({obj.PKModel.enhancement_data}.'), quantiles), 'rs-', ...
  obj.PKModel(1).t_fit, quantile(cell2mat({obj.PKModel.enhancement_fit}.'), quantiles), 'b-');
grid on;
title('Quantiles 0.1, 0.5, 0.9');
legend(h([1 1+length(quantiles)]), {'Data', 'Fit'});
xlabel('Time (min)');
ylabel('Enhancement');
increase_font;

% Histogram of Ktrans and kep
figure;
subplot(2, 2, 1);
hist(ktrans, sqrt(length(ktrans)));
grid on;
xlabel('K_{trans}');
subplot(2, 2, 3);
hist(kep, sqrt(length(kep)));
grid on;
xlabel('k_{ep}');
subplot(2, 2, [2 4]);
scatter(ktrans, kep, 'o');
hold on;
line_lims = [0, min([max(ktrans), max(kep)])];
plot(line_lims, line_lims, 'r-', 'linewidth', 2);
grid on;
xlabel('K_{trans}');
ylabel('k_{ep}');
increase_font;
