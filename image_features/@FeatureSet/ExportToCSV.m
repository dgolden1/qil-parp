function ExportToCSV(obj, filename, varargin)
% Export feature vector to CSV
% ExportToCSV(obj, filename, varargin)
% 
% PARAMETERS
% b_ids (default: true)
% b_pretty_names (default: false)
% b_include_response (default: false)
% additional_columns (default: {})

% By Daniel Golden (dgolden1 at stanford dot edu) June 2013
% $Id$

%% Parse input arguments
p = inputParser;
p.addParamValue('b_ids', true);
p.addParamValue('b_pretty_names', false);
p.addParamValue('b_include_response', false);
p.addParamValue('additional_columns', {});
p.parse(varargin{:});

%% Run
if p.Results.b_pretty_names
  table = obj.FeaturePrettyNames;
else
  table = obj.FeatureNames;
end

table = [table; num2cell(obj.FeatureVector)];

if ~isempty(p.Results.additional_columns)
  if size(p.Results.additional_columns, 1) ~= size(table, 1)
    error('additional_columns must contain a header and %d rows (%d total rows)', size(table, 1) - 1, size(table, 1));
  end
  if ~iscell(p.Results.additional_columns)
    error('additional_columns must be a cell array');
  end
  
  table = [table, p.Results.additional_columns];
end

if p.Results.b_include_response
  response_row_idx = size(table, 2);
  table(1, response_row_idx) = obj.ResponseName;
  table(2:end, response_row_idx) = obj.Response;
end

if p.Results.b_ids
  table = [[{'ID'}; obj.PatientIDs(:)], table];
end

csvwrite_dan(filename, table);
