classdef PARPDB < handle
  % The PARP DCE-MRI database
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$

  properties
    Dirname
    PreOrPostChemo
    CommonPixelSpacing % Common pixel spacing for all images (mm)
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method
    
    Filename
    DirSuffix
  end
  
  methods
    function obj = PARPDB(str_pre_or_post_chemo, suffix_or_common_size)
      % PARPDB(str_pre_or_post_chemo, dirname_suffix)
      if nargin == 0
        return;
      end
      
      if ~ismember(str_pre_or_post_chemo, {'pre', 'post'})
        error('str_pre_or_post_chemo must be either ''pre'' or ''post''');
      end
      
      if ~exist('suffix_or_common_size', 'var') || isempty(suffix_or_common_size)
        dirname_suffix = '';
      elseif ischar(suffix_or_common_size)
        dirname_suffix = suffix_or_common_size;
        if dirname_suffix(1) ~= '_'
          dirname_suffix = ['_' dirname_suffix];
        end
      else
        dirname_suffix = sprintf('_res_%0.1f', suffix_or_common_size);
        obj.CommonPixelSpacing = suffix_or_common_size;
      end
      
      obj.Dirname = fullfile(qilcasestudyroot, 'parp', 'parp_db', sprintf('%s%s', str_pre_or_post_chemo, dirname_suffix));
      obj.PreOrPostChemo = str_pre_or_post_chemo;
      
      if ~exist(obj.Dirname, 'dir')
        % Create DB directory if it doesn't exist
        mkdir(obj.Dirname);
        fprintf('Created %s\n', obj.Dirname);
      else
        % Load existing DB
        obj = LoadDB(obj, [], false);
      end
    end
    
    function value = get.Filename(obj)
      value = fullfile(obj.Dirname, 'parpdb.mat');
    end
    
    function value = get.DirSuffix(obj)
      dirname_no_path = just_filename(obj.Dirname);
      value = regexprep(dirname_no_path, '(^pre_)|(^post)', '');
    end
  end
  
  methods (Static)
    [patient_id, str_pre_or_post_chemo] = GetPatientIDFromFilename(filename)
    obj = CreateDBFromExistingFiles(str_pre_or_post_chemo, varargin)
    varargout = ListDBs
    lasso_runs = RunLassoModelMultiDB(obj, feature_param_vals, response_vec, varargin)
    BatchRunModelsForPaper
    BatchPlotLassoPaperResults(b_save)
    CompareGLCMFeatures(pdb1, pdb2, varargin)
    CompareKineticMaps(pdb1, pdb2, varargin)
  end
end
