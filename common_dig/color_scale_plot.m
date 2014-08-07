% color_scale_plot

% By Daniel Golden (dgolden1 at stanford dot edu) June 2008
% $Id: color_scale_plot.m 13 2012-08-10 19:30:42Z dgolden $

close all;
clear;

j = flipdim(reshape(jet, 64, 1, 3), 1);
image(j);

figure_squish(gcf, 10, 1);
set(gca, 'yticklabel', '');
set(gca, 'xticklabel', '');

xlabel(sprintf('Less\nIntense'));
title(sprintf('More\nIntense'));
increase_font(gcf, 14);
