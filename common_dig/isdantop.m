function b = isdantop
% Return true if hostname is dantop-air*, false otherwise

% By Daniel Golden May 2014

persistent b_persistent
if isempty(b_persistent)
  b_persistent = ismember(hostname, {'dantop-air', 'dantop-air.local'});
end
b = b_persistent;
