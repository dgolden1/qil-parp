function obj = load_object_properties(input_filename, varargin)
% Load an object from a file which contains variables corresponding to object properties
% obj = load_object_properties(filename, 'param', value, ...)
% 
% PARAMETERS
% output_class: normally, output class is determined from the CLASSNAME variable stored
% in the file. The user can specify an alternate class with this variable (e.g., a
% superclass)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: load_object_properties.m 194 2013-02-21 21:06:12Z dgolden $

%% Parse inpute arguments
p = inputParser;
p.addParamValue('output_class', []);
p.parse(varargin{:});

%% Load
input_struct = load(input_filename);

if isempty(p.Results.output_class)
  output_class = input_struct.CLASSNAME;
else
  output_class = p.Results.output_class;
end

% Create output object
obj = eval('%s', output_class);

%% Assign properties
fn = fieldnames(rmfield(input_struct, 'CLASSNAME'));

% Don't assign dependent fields
dependent_field_idx = ~cellfun(@isempty, regexp(fn, '^DEPENDENT', 'once'));
fn(dependent_field_idx) = [];

for kk = 1:length(fn)
  obj.(fn{kk}) = input_struct.(fn{kk});
end