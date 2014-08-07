function [dummy_var, label_list] = label_to_dummy(labels, master_label)
% Convert labels to dummy variables
% [dummy_var, label_list] = label_to_dummy(labels, master_label)
% 
% Empty labels are set to NaN in all columns of dummy_var
% 
% master_label will be prepended to each label in label_list

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: label_to_dummy.m 151 2013-01-22 18:35:27Z dgolden $

%% Setup
if ~exist('master_label', 'var') || isempty(master_label)
  master_label = repmat({''}, 1, size(labels, 2));
end
if ~iscell(master_label)
  master_label = {master_label};
end
if length(master_label) ~= size(labels, 2)
  error('Master label must have length equal to the number of columns in labels');
end

dummy_var = [];

%% create dummy variables
% Allow multiple categories of labels; each category is another column
label_list = {};
for kk = 1:size(labels, 2)
  labels_nom = nominal(labels(:,kk));
  dummy_var = [dummy_var dummyvar(labels_nom)];
  
  this_label_list = getlabels(labels_nom);
  this_label_list = cellfun(@(x) [master_label{kk} ' ' x], this_label_list, 'UniformOutput', false);
  label_list = [label_list this_label_list];
end
