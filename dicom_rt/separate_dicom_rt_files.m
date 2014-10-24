function separate_dicom_rt_files
% Move patient DICOM-RT files out of the dicom_anon folder and into the dicomrt folder

% By Daniel Golden (dgolden1 at stanford dot edu) February 2013
% $Id$

b_dicom_to_dicomrt = true;

dicom_dir = fullfile(qilcasestudyroot, 'diehn_lung', 'dicom_anon');
dicom_rt_dir = fullfile(qilcasestudyroot, 'diehn_lung', 'dicomrt');

if b_dicom_to_dicomrt
  d = dir(dicom_dir);
else
  d = dir(dicom_rt_dir);
end

for kk = 1:length(d)
  if isempty(regexp(d(kk).name, '\d{1,3}-[a-zA-Z]{2}', 'once'))
    % Not a patient dir
    continue;
  end
  
  if b_dicom_to_dicomrt
    this_input_dir = fullfile(dicom_dir, d(kk).name);
  else
    this_input_dir = fullfile(dicom_rt_dir, d(kk).name);
  end
  
  filelist = find_files_unix(this_input_dir, '-type f -name "RS*.dcm" -or -name "RP*.dcm" -or -name "RD*.dcm"');
  
  for jj = 1:length(filelist)
    if b_dicom_to_dicomrt
      output_filename = strrep(filelist{jj}, '/dicom_anon/', '/dicomrt/');
    else
      output_filename = strrep(filelist{jj}, '/dicomrt/', '/dicom_anon/');
    end
    
    output_dir = fileparts(output_filename);
    
    if ~exist(output_dir, 'dir')
      mkdir(output_dir);
    end
    
    movefile(filelist{jj}, output_filename);
    fprintf('Moved %s to %s\n', just_filename(filelist{jj}), output_filename);
  end
end
