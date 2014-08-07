function labels = dummy_to_label(dummyvars, label_names)
% Convert from dummy variables into labels
% labels = dummy_to_label(dummyvars, label_names)

% By Daniel Golden (dgolden1 at stanford dot edu) July 2012
% $Id: dummy_to_label.m 151 2013-01-22 18:35:27Z dgolden $

% Label categories end on each column where the cumulative sum across all
% columns is an integer
dummy_cumsum = cumsum(dummyvars, 2);
var_sum = sum(dummyvars, 2);

if ~all(nanvar(var_sum) == 0 & ... All rows add up to the same number and...
        fpart(var_sum) == 0 | ...            All rows add up to integer
        all(isnan(dummyvars), 2))               % OR all values in a row are nan
  error('Dummy variables must add up to an integer when summed across columns');
end

num_label_categories = nanmedian(var_sum);

% If we have dummy variables with multiple categories of labels, loop over
% the categories; if not, make a cell with just one category

labels = cell(size(dummyvars, 1), num_label_categories);
start_idx = 1; % Column index into dummyvars of the beginning of this label category

% For each label category...
for jj = 1:num_label_categories
  if num_label_categories > 1
    % If there's more than one category of labels, we need to deliniate dummyvars to
    % find the columns in which this variable category resides
    end_idx = find(all(diff(dummy_cumsum) == 0 | isnan(diff(dummy_cumsum)), 1) & (1:size(dummyvars, 2)) >= start_idx, 1, 'first');
  else
    % Otherwise, all the rows belong to this variable
    end_idx = size(dummyvars, 2);
  end
  
  this_dummy_idx = start_idx:end_idx;
  this_dummy = dummyvars(:,this_dummy_idx);
  this_label_names = label_names(this_dummy_idx);
  
  % For each label in this category...
  for kk = 1:length(this_label_names)
    idx_nonan = ~isnan(this_dummy(:,kk));
    b_this_label_idx(idx_nonan) = logical(this_dummy(idx_nonan,kk));
    b_this_label_idx(~idx_nonan) = false;
    labels(b_this_label_idx, jj) = this_label_names(kk);
  end
  % Set the label of any dummy variables that were NaN to ''
  labels(~idx_nonan) = {''};
  
  start_idx = start_idx + length(this_label_names);
end
