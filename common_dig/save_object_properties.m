function save_object_properties(output_filename, obj, varargin)
% Save an object by saving all of its non-dependent properties to a file
% save_object_properties(obj, output_filename, 'param', value)
% 
% The advantage of this approach is that individual properties can then be loaded
% without loading the whole file
% 
% PARAMETERS
% b_verbose: print save confirmation
% b_save_dependent_vars: save dependent variables (default: false)

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id: save_object_properties.m 194 2013-02-21 21:06:12Z dgolden $

%% Parse input arguments
p = inputParser;
p.addParamValue('b_verbose', false);
p.addParamValue('b_save_dependent_vars', false);
p.parse(varargin{:});

%% Assign object properties to struct
classname = class(obj);
mc = metaclass(obj);

if any(strcmp({mc.PropertyList.Name}, 'CLASSNAME'))
  error('Unable to store class with property ''CLASSNAME''');
end

output_struct.CLASSNAME = classname;

for kk = 1:length(mc.PropertyList)
  this_property = mc.PropertyList(kk);
  if ~this_property.Dependent
    output_struct.(this_property.Name) = obj.(this_property.Name);
  elseif p.Results.b_save_dependent_vars
    output_struct.(['DEPENDENT_' this_property.Name]) = obj.(this_property.Name);
  end
end

%% Save
save(output_filename, '-struct', 'output_struct');

if p.Results.b_verbose
  fprintf('Saved %s\n', output_filename);
end