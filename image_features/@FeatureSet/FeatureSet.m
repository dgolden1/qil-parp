classdef FeatureSet
  % A set of features for some patients
  
  % TODO: in the future, this class could inherit from the built-in Matlab dataset class
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$
  
  properties
    FeatureVector % NxP matrix of P features for N patients
    PatientIDs % Nx1 vector of patient IDs (cell string or double)
    FeatureNames % 1xP vector of feature names (cell string)
    FeaturePrettyNames % feature names suitable for printing (cell string); may be the same as FeatureNames
    FeatureCategoryName = ''; % Description of this feature set
    FeatureCategoryPrettyName = ''; % Pretty description of this feature set
    
    Response % The response (necessary for some methods)
    ResponseName % Description of response
    
    Comment = ''; % Use for any miscellaneous info
  end
  
  properties (Dependent, SetAccess = private)
    % Dependent properties with no "set" method
    
    bAllFeaturesValid % True if no feature values are NaN
    bResponseCategorical % Response is categorical, as opposed to continuous
    bFeaturesCategorical % All features are categorical
  end
  
  methods
    function obj = FeatureSet(varargin)
      % Inputs can be FeatureSet(FeatureVector, PatientIDs, FeatureNames, FeaturePrettyNames, FeatureCategoryName, FeatureCategoryPrettyName)
      % or
      % FeatureSet(FeatureStruct, FeaturePrettyNames, FeatureCategoryName, FeatureCategoryPrettyName)
      
      if nargin == 0
        return;
      elseif isstruct(varargin{1})
        % Input was a struct; assign args, convert to object via internal
        % function and return
        narginchk(1, 4);
        FeatureStruct = varargin{1};
        if nargin >= 2
          FeaturePrettyNames = varargin{2};
        else
          FeaturePrettyNames = [];
        end
        if nargin >= 3
          FeatureCategoryName = varargin{3};
        else
          FeatureCategoryName = '';
        end
        if nargin >= 4
          FeatureCategoryPrettyName = varargin{4};
        else
          FeatureCategoryPrettyName = FeatureCategoryName;
        end
        
        obj = FeatureSet.CreateFromStruct(FeatureStruct, FeaturePrettyNames, FeatureCategoryName, FeatureCategoryPrettyName);
        return;
      else
        % Input was a feature vector; assign args and proceed through this
        % method
        narginchk(3, 6);
        FeatureVector = varargin{1};
        PatientIDs = varargin{2};
        FeatureNames = varargin{3};
        if nargin >= 4
          FeaturePrettyNames = varargin{4};
        else
          FeaturePrettyNames = [];
        end
        if nargin >= 5
          FeatureCategoryName = varargin{5};
        else
          FeatureCategoryName = '';
        end
        if nargin >= 6
          FeatureCategoryPrettyName = varargin{6};
        else
          FeatureCategoryPrettyName = FeatureCategoryName;
        end
      end
      
      % Ensure that if PatientIDs are strings, they are cellstrings
      if ischar(PatientIDs)
        PatientIDs = {PatientIDs};
      end
      
      % If a single feature is given where the name is passed as a string, convert to a
      % cellstring
      if ischar(FeatureNames)
        FeatureNames = {FeatureNames};
      end
      if ischar(FeaturePrettyNames)
        FeaturePrettyNames = {FeaturePrettyNames};
      end
      
      if size(FeatureVector, 1) ~= length(PatientIDs) 
        error('Num rows of FeatureVector (%d) must equal length of PatientIDs (%d)', size(FeatureVector, 1), length(PatientIDs));
      end
      if size(FeatureVector, 2) ~= length(FeatureNames)
        error('Num cols of FeatureVector (%d) must equal length of FeatureNames (%d)', size(FeatureVector, 2), length(FeatureNames));
      end
      
      obj.FeatureVector = FeatureVector;
      obj.PatientIDs = PatientIDs;
      obj.FeatureNames = sanitize_struct_fieldname(FeatureNames);
      
      if exist('FeaturePrettyNames', 'var') && ~isempty(FeaturePrettyNames)
        if length(FeatureNames) ~= length(FeaturePrettyNames)
          error('Length of FeatureNames (%d) must equal length of FeaturePrettyNames (%d)', length(FeatureNames), length(FeaturePrettyNames));
        end
        
        obj.FeaturePrettyNames = FeaturePrettyNames;
      else
        % If pretty names are not provided, just set equal to the normal
        % feature names
        obj.FeaturePrettyNames = FeatureNames;
      end
      
      if ~isempty(FeatureCategoryName)
        FeatureCategoryName = sanitize_struct_fieldname(FeatureCategoryName);
        obj.FeatureCategoryName = FeatureCategoryName;
      end
      if ~isempty(FeatureCategoryPrettyName)
        obj.FeatureCategoryPrettyName = FeatureCategoryPrettyName;
      end
      obj = PrependStrToFeatureNames(obj, FeatureCategoryName, FeatureCategoryPrettyName);
      
      obj = SortFeatures(obj);
      obj = SortPatients(obj);
    end
    
    function value = get.bAllFeaturesValid(obj)
      value = all(isfinite(obj.FeatureVector(:)));
    end
    
    function value = get.bResponseCategorical(obj)
      value = iscellstr(obj.Response);
    end
    
    function value = get.bFeaturesCategorical(obj)
      value = isequal(double(unique(obj.FeatureVector(:))), [0 1].');
    end
    
    function obj_diff = minus(obj1, obj2)
      % Get difference between two analogous feature sets
      % The FeatureCategoryName will be set to 'diff', so the user may want
      % to prepend a more specific suffix manually by running, e.g., 
      % >>> obj_diff.FeatureCategoryName = ['my feature ' obj_diff.FeatureCategoryName]
      
      % Get common patient ids
      patient_ids_common = intersect(obj1.PatientIDs, obj2.PatientIDs);
      
      idx_patients_1 = ismember(patient_ids_1, patient_ids_common);
      idx_patients_2 = ismember(patient_ids_2, patient_ids_common);
      
      if ~isequal(obj1.FeatureNames, obj2.FeatureNames) || ~isequal(obj1.FeaturePrettyNames, obj2.FeaturePrettyNames)
        error('Features for FeatureSet objects differ');
      end
      
      X_diff = obj1.FeatureVector(idx_patients_1, :) - obj2.FeatureVector(idx_patients_2, :);
      
      obj_diff = FeatureSet(X_diff, patient_ids_common, obj1.FeatureNames, obj1.FeaturePrettyNames, 'diff');
    end
  end
  
  methods (Static)
    % Get feature set from XLS file
    feature_set = GetFeatureSetXLS(xls_filename, xls_sheetname, patient_id_col_name, feature_category_name, varargin);
    
    % Make feature set with fake features
    feature_set = MakeFakeFeatures(num_patients, num_features);
  end
  
  methods (Access = protected, Static)
    obj = CreateFromStruct(FeatureStruct, FeaturePrettyNames, FeatureCategoryName, FeatureCategoryPrettyName)
  end
end

function cellstr_with_prefix = prepend_str_to_cell(prefix, cellstr, b_sanitize_prefix)
% Tack a prefix onto each string in a cell array of strings

if b_sanitize_prefix
  prefix = sanitize_struct_fieldname(prefix);
  separator = '_';
else
  separator = ' ';
end

cellstr_with_prefix = cellfun(@(x) [prefix separator x], cellstr, 'UniformOutput', false);

end

function patient_ids_cellstr = patient_ids_to_cellstr(patient_ids)
% Ensure that patient IDs are a cell array of strings for printing

if isnumeric(patient_ids)
  patient_ids_cellstr = cellfun(@(x) num2str(x, '%03d'), num2cell(patient_ids), 'UniformOutput', false);
elseif iscellstr(patient_ids)
  patient_ids_cellstr = patient_ids;
elseif ischar(patient_ids)
  patient_ids_cellstr = {patient_ids};
end

end
