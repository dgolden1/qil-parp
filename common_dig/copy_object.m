function obj_out = copy_object(obj_in, classname_out)
% Cast an object from one class to another by just copying properties
% See http://www.mathworks.com/support/solutions/en/data/1-8M25OE/index.html?product=SL&solution=1-8M25OE

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: copy_object.m 164 2013-01-29 19:42:43Z dgolden $

% Create empty output class
eval(sprintf('obj_out = %s;', classname_out));

C = metaclass(obj_in);
P = C.Properties;
for k = 1:length(P)
  if ~P{k}.Dependent
    obj_out.(P{k}.Name) = obj_in.(P{k}.Name);
  end
end