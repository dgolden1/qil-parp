function nominal_print_summary(nom_or_strcell, varargin)
% Print summary of a nominal object with each category in a single line
% nominal_print_summary(nom_or_strcell, varargin)
% 
% Prints better than the summary() method of the nominal class for long names
% 
% PARAMETERS
% ids: IDs (e.g., patient IDs) for each label
% b_percent: also print percents (default: false)
% b_include_undefined: include empty strings (undefined labels) in output summary
%  (default: true)

% By Daniel Golden (dgolden1 at stanford dot edu) October 2012
% $Id: nominal_print_summary.m 337 2013-07-10 16:25:15Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('ids', {});
p.addParamValue('b_percent', false);
p.addParamValue('b_include_undefined', true);
p.parse(varargin{:});

%% Allow cell input, listing categories
if iscell(nom_or_strcell)
  nom_or_strcell = strtrim(nom_or_strcell);
  nom = nominal(nom_or_strcell);
  b_input_strcell = true;
elseif islogical(nom_or_strcell)
  nom_str(nom_or_strcell) = {'True'};
  nom_str(~nom_or_strcell) = {'False'};
  nom = nominal(nom_str);
  b_input_strcell = false;
elseif isnumeric(nom_or_strcell)
  nom_or_strcell = cellfun(@num2str, num2cell(nom_or_strcell(:)), 'uniformoutput', false);
  nom = nominal(nom_or_strcell);
  b_input_strcell = true;
else
  nom = nom_or_strcell;
  b_input_strcell = false;
end

%% Get labels and counts
labels = getlabels(nom);
counts = levelcounts(nom);

if p.Results.b_include_undefined && any(isundefined(nom))
  labels{end+1} = '<undefined>';
  counts(end+1) = sum(isundefined(nom));
end

%% Print
for kk = 1:length(labels)
  
  if p.Results.b_percent
    % Add info about percent
    percent_str = sprintf(' (%2.0f%%)', counts(kk)/sum(counts)*100);
  else
    percent_str = '';
  end
  
  fprintf('%3d%s  %s', counts(kk), percent_str, labels{kk});
  
  if b_input_strcell && ~isempty(p.Results.ids)
    idx_ids = find(strcmp(nom_or_strcell, labels{kk}));
    fprintf('  IDs: ');
    for jj = 1:length(idx_ids)
      this_id = p.Results.ids(idx_ids(jj));

      % Convert numbers to strings
      if iscell(this_id)
        this_id = this_id{1};
      elseif isnumeric(this_id)
        this_id = num2str(this_id);
      end
      
      if jj < length(idx_ids)
        fprintf('%s, ', this_id);
      else
        fprintf('%s', this_id);
      end
    end
  end
  
  fprintf('\n');
end