function increase_font(axis_handle, fontsize, fontname)
% increase_font(axis_handle, fontsize, fontname)
% Changes all font sizes of a given axis to be of the given fontsize and
% fontname
% 
% If fontsize is not specified, it defaults to 16
% If fontname is not specified, it defaults to Times New Roman
% 
% By Daniel Golden (dgolden1@stanford.edu) Feb 26, 2007

% $Id: increase_font.m 2 2012-08-02 23:59:40Z dgolden $

%% Setup

if ~exist('axis_handle', 'var') || isempty(axis_handle)
	axis_handle = gcf;
end
if ~exist('fontsize', 'var') || isempty(fontsize)
	fontsize = 16;
end
if ~exist('fontname', 'var') || isempty(fontname)
	fontname = 'Times New Roman';
end

%% The old way
% % This is a figure
% if axis_handle == floor(axis_handle)
% 	h = findall(axis_handle, '-property', 'FontSize');
% 	set(h, 'FontSize', fontsize);
% % This is an axis
% else
% 	% Axis labels
% 	set(axis_handle, 'FontSize', fontsize);
% 
% 	% xlabel, ylabel
% 	set(get(axis_handle, 'xlabel'), 'FontSize', fontsize);
% 	set(get(axis_handle, 'ylabel'), 'FontSize', fontsize);
% 	set(get(axis_handle, 'title'), 'FontSize', fontsize);
% 
% 	% Colorbar
% 	x = findobj(gcf, 'Tag', 'Colorbar');
% 	if length(x) > 0
% 		h_colorbars = findobj(gcf, 'Tag', 'Colorbar');
% 	% 		if isscalar(h_colorbars) % Turn h_colorbars into a cell array if it isn't one
% 	% 			h_bars_temp = h_colorbars;
% 	% 			h_colorbars = cell(size(h_bars_temp));
% 	% 			for kk = 1:length(h_colorbars)
% 	% 				h_colorbars{kk} = h_bars_temp(kk);
% 	% 			end
% 	% 		end
% 
% 		for kk = length(h_colorbars)
% 			set(h_colorbars(kk), 'FontSize', fontsize);
% 			set(get(h_colorbars(kk), 'xlabel'), 'FontSize', fontsize);
% 			set(get(h_colorbars(kk), 'ylabel'), 'FontSize', fontsize);
% 			set(get(h_colorbars(kk), 'title'), 'FontSize', fontsize);
% 		end
% 	end
% end

%% The new way
set(findall(axis_handle, '-Property', 'FontSize'), 'FontSize', fontsize);

% Class-up the font
set(findall(axis_handle, '-Property', 'FontName'), 'FontName', fontname);
