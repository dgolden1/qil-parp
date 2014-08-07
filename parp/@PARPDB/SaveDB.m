function SaveDB(obj)
% Save database to a file

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

% Determine common res from directory name if it isn't set
if isempty(obj.CommonPixelSpacing)
  dirname_no_path = just_filename(obj.Dirname);
  if ~isempty(strfind(dirname_no_path, 'common_res'))
    common_res_str = regexprep(dirname_no_path, '.*common_res_([0-9]+\.[0-9])_.*', '$1');
    obj.CommonPixelSpacing = str2double(common_res_str);
  end
end

str_pre_or_post_chemo = obj.PreOrPostChemo;
common_pixel_spacing = obj.CommonPixelSpacing;
dir_suffix = obj.DirSuffix;

save(obj.Filename, 'str_pre_or_post_chemo', 'common_pixel_spacing', 'dir_suffix');
fprintf('Saved %s\n', obj.Filename);
