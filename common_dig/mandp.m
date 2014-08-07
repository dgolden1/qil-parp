function mandp(classname, b_full)
% Print properties and methods of a class
% mandp(classname, b_full)
% 
% INPUTS
% classname: name or object of a class
% b_full: if false (default) just prints method names; if true, prints full descriptions

% By Daniel Golden (dgolden1 at stanford dot edu) January 2013
% $Id: mandp.m 198 2013-02-25 21:51:48Z dgolden $

if ~exist('b_full', 'var') || isempty(b_full)
  b_full = false;
end

if ~ischar(classname)
  classname = class(classname);
end

if ~exist(classname, 'class')
  error('No class %s', classname);
end

properties(classname);

fprintf('%s\n', repmat('-', 1, 30));

if b_full
  methods(classname, '-full');
else
  methods(classname);
end