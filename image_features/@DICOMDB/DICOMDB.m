classdef DICOMDB
  % A database of DICOMImage objects
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$

  properties
    DBFilename = ''

    DICOMList = DICOMImage.empty
    MapUID % containers.Map object to look up index into DICOMList by UID
    MapFilename % containers.Map object to look up index into DICOMList by filename
  end
  
  methods
    function obj = DICOMDB(DICOMList)
      if nargin == 0
        return;
      end
      
      [~, sort_idx] = sort([DICOMList.SliceCoordmm], 'ascend');
      obj.DICOMList = DICOMList(sort_idx);
      
      obj = RefreshMaps(obj);
    end
  end
end
