function feature_set = GetFeatureSetXLS(xls_filename, varargin)
% Get features from a spreadsheet
% feature_set = FeatureSet.GetFeatureSetXLS(xls_filename, 'param', value, ...)
% 
% In XLS/XLSX file:
% First row should be headings
% Second row should be labels, either blank, 'Quantitative' or 'Semantic'
%  describing whether the feature is continuous or categorical
% Third through last rows represent different patients/nodules
% 
% PARAMETERS
% patient_id_col_name: the (exact) string for the header of the column
%  containing the patient IDs; if not given, first column is assumed to 
%  be patient ID column
% feature_category_name: the name describing this feature set (e.g.,
%  'Semantic' or 'Clinical' or 'BI-RADS')
% xls_sheetname: name of XLS sheet (leave blank for first sheet)
% b_force_patient_id_str: force patient IDs to be returned as strings, even if they're
%  numeric (default: false)

% By Daniel Golden (dgolden1 at stanford dot edu) November 2012
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('feature_category_name', '');
p.addParamValue('xls_sheetname', '');
p.addParamValue('patient_id_col_name', '');
p.addParamValue('b_force_patient_id_str', false);
p.parse(varargin{:});

%% Load data
if ~isempty(p.Results.xls_sheetname)
  [~, ~, raw] = xlsread(xls_filename, xls_sheetname);
else
  [~, ~, raw] = xlsread(xls_filename);
end

% Remove empty rows and columns
idx_cell_nan = cellfun(@(x) isnumeric(x) && isnan(x), raw);
bad_rows = all(idx_cell_nan, 2);
raw(bad_rows, :) = [];

idx_cell_nan = cellfun(@(x) isnumeric(x) && isnan(x), raw);
bad_cols = all(idx_cell_nan, 1);
raw(:, bad_cols) = [];

%% Parse Patient IDs
col_names = raw(1,:);

if isempty(p.Results.patient_id_col_name)
  patient_id_col = 1;
else
  patient_id_col = strcmp(col_names, p.Results.patient_id_col_name);
  if sum(patient_id_col) ~= 1
    fprintf('Found %d columns with name %s; expected 1\n', sum(patient_id_col), p.Results.patient_id_col_name);
  end
end
patient_id = raw(3:end, patient_id_col);

% Some kludges for either integer or xxx.xxx type patient ids assuming at
% least half of the patient ids are numeric
b_numeric = cellfun(@isnumeric, patient_id);
if sum(b_numeric) > length(b_numeric)/2
  if p.Results.b_force_patient_id_str
    b_patient_id_numeric = cellfun(@isnumeric, patient_id);
    patient_id(b_patient_id_numeric) = cellfun(@num2str, patient_id(b_patient_id_numeric), 'uniformoutput', false);
  elseif all(fpart(cell2mat(patient_id(b_numeric))) == 0)
    % Set patient IDs to integers
    patient_id = cell2mat(patient_id);
  else
    % Set patient IDs to cell string
    patient_id = cellfun(@(x) num2str(x, '%05.1f'), patient_id, 'UniformOutput', false);
  end
end

%% Parse features
semantic_cols = strcmpi(raw(2,:), 'Semantic');
quantitative_cols = strcmpi(raw(2,:), 'Quantitative');

if sum(semantic_cols) == 0 && sum(quantitative_cols) == 0
  error('Row two should be labeled ''Semantic'' or ''Quantitative''');
end

feature_cols = find(semantic_cols | quantitative_cols);

X_names = cell(0);
X = double.empty;
for kk = 1:length(feature_cols)
  col = feature_cols(kk);
  col_name = col_names{col};
  
  this_x_idx = length(X_names) + 1;
  
  b_semantic = semantic_cols(col);
  vals = raw(3:end, col);
  if all(cellfun(@(x) isnumeric(x) || islogical(x), vals))
    vals = cell2mat(vals);
  end
  
  vals = fix_blank_cell_bug(vals);

  if b_semantic
    % This is a semantic feature column
    if iscell(vals) && any(cellfun(@ischar, vals)) && ~all(cellfun(@ischar, vals))
      % Some, but not all, values are strings; set the NaNs to empty strings and convert
      % everything else
      vals(cellfun(@(x) isnumeric(x) && isnan(x), vals)) = {''};
      
      idx_numeric = ~cellfun(@ischar, vals);
      vals(idx_numeric) = cellfun(@num2str, vals(idx_numeric), 'uniformoutput', false);
      
      % If vals is still not a cellstring, then this is an error
      if ~iscellstr(vals)
        error('Column %s contains invalid mix of strings and other types', col_name);
      end
    end
    
    if iscell(vals)
      vals_unique = unique(vals(~cellfun(@isempty, vals)));
    else
      vals_unique = unique(vals(~isnan(vals)));
    end
    
    if length(vals_unique) == 2 && iscellstr(vals_unique)
      % Only two possible values and they're strings; output is one column,
      % either 0 or 1
      positive_label = vals_unique{1};
      X_names{this_x_idx} = [col_name ' ' positive_label];
      X(:,this_x_idx) = strcmp(vals, positive_label);
      
      % Set missing data to NaN
      nan_idx = cellfun(@isempty, vals);
      X(nan_idx, this_x_idx) = nan;
    elseif ~iscellstr(vals_unique) && length(vals_unique) == 2
      % Only two possible values and they're numeric; output is one column, either 0 or
      % 1 (or NaN)
      X_names{this_x_idx} = col_name;
      X(:,this_x_idx) = vals;
    elseif length(vals_unique) > 2
      % More than two values
      if ~iscellstr(vals)
        % Numeric values
        vals = cellfun(@num2str, num2cell(vals), 'UniformOutput', false);
        vals(strcmp(vals, 'NaN')) = {''};
      end
        
      [dummy_var, label_list] = label_to_dummy(vals, col_name);
      
      % Multiple entries in X
      this_x_idx = this_x_idx:(this_x_idx + length(label_list) - 1);
      
      X_names(this_x_idx) = label_list;
      X(:,this_x_idx) = dummy_var;
    elseif length(vals_unique) < 2
      % Only one value in column
      warning('Column %s is invariant; skipping', col_name);
      continue;
    else
      error('This shouldn''t happen');
    end
  else
    % This is a quantitative feature column
    X_names{this_x_idx} = col_name;
    X(:,this_x_idx) = vals;
  end
end

%% Save as FeatureSet
feature_set = FeatureSet(X, patient_id_tostr(patient_id), strtrim(X_names), strtrim(X_names), p.Results.feature_category_name);


function vals = fix_blank_cell_bug(vals)
%% Function: fix a bug in xlsread reading blank cells
% A bug in Matlab's excel xlsread function sometimes sets cells that are set blank 
% by a formula to crazy values. An example value is '</c></row><row r="3" spans="1:2"><c r="A3" s="3" t="s"><v>0'
% The crazy values always start with </c>
  
if iscell(vals)
  idx_crazy_values = cellfun(@(x) ischar(x) && ~isempty(regexp(x, '^</c>', 'once')), vals);
  vals(idx_crazy_values) = {''};
end
