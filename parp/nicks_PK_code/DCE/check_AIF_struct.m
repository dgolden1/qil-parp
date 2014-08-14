
function valid = check_AIF_struct(AIF_Struct)

valid = false;

if ~isfield(AIF_Struct, 'a')
  disp('AIF struct does not contain the field "a"');
  return;
end

if ~isfield(AIF_Struct, 'm')
  disp('AIF struct does not contain the field "m"');
  return;
end

if length(AIF_Struct.a) ~= 2
  disp('AIF struct field "a" should be a 2 element vector');
  return;
end

if length(AIF_Struct.m) ~= 2
  disp('AIF struct field "m" should be a 2 element vector');
  return;
end

valid = true;
