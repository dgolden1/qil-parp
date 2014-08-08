function addpaths
% Add qil paths that supersede CellScope ones

% base_path = '/Users/dgolden/Documents/qil/qil_software/qil';
base_path = qilsoftwareroot;
other_paths = {'', 'common_dig', 'dicom_util', 'image_features', 'parp'};

for kk = 1:length(other_paths)
  addpath(fullfile(base_path, other_paths{kk}));
end
