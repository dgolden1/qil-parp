function addpaths
% Add qil paths

% base_path = '/Users/dgolden/Documents/qil/qil_software/qil';
base_path = qilsoftwareroot;
other_paths = {'', 'common_dig', 'dicom_util', 'image_features', 'parp'};

for kk = 1:length(other_paths)
  addpath(fullfile(base_path, other_paths{kk}));
end

% Remove paths outside qil directory
if isdantop
  p = path;
  p_cell = strsplit(p, ':');
  paths_to_remove = p_cell(~cellfun(@isempty, regexp(p_cell, '^/Users/dgolden/software', 'once')));
  for kk = 1:length(paths_to_remove)
    rmpath(paths_to_remove{kk});
  end
end
