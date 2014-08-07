function feature_set = BatchFunFeature(obj, fun_handle, varargin)
% Run some PARPDCEMRIImage method (fun_handle) over all PARPDCEMRIImage objects in the
% database and return the result unified FeatureSet object
% feature_set = BatchFunFeature(obj, fun_handle, varargin)
% 
% Assumes output is a FeatureStruct for each PARPDCEMRIImage object and contatenates
% them vertically
% 
% varargin contains the arguments for the function in fun_handle

% By Daniel Golden (dgolden1 at stanford dot edu) December 2012
% $Id$

fs_cell = BatchFun(obj, fun_handle, 'fun_args', varargin);

% Contatenate FeatureSet objects vertically (i.e., add new patients with same features)
feature_set = FeatureSet.empty;
for kk = 1:length(fs_cell)
  feature_set = [feature_set; fs_cell{kk}];
end
