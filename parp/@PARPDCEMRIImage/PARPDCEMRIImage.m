classdef PARPDCEMRIImage < DCEMRIImage
  % A DCEMRIImage with some special PARP aspects
  
  methods
    function obj = PARPDCEMRIImage(varargin)
      % Just call DCEMRIImage constructor with all arguments
      obj = obj@DCEMRIImage(varargin{:});
      
      if nargin == 0
        return;
      end
      
      obj.LesionCenter = GetLesionCenterFromSpreadsheet(obj);
    end
  end
  
  methods (Static)
    parp_dce_mri_image = CreateFromExistingOldStyle(patient_id, str_pre_or_post_chemo)
  end
end
