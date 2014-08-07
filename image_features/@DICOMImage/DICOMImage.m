classdef DICOMImage
  % A DICOM image with some essential information
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$

  properties
    Filename
    PatientID
    SeriesDescription
    SeriesCategory
    
    SOPInstanceUID
    SeriesInstanceUID
    StudyInstanceUID

    Time % Datenum of beginning of acquisition
    Modality
    
    DICOMCoordsmm % Struct with fields x, y and z representing coordinates in mm (one of the three should be a scalar)
    XCoordmm % DICOM coordinate of x-axis (mm)
    YCoordmm % DICOM coordinate of y-axis (mm)
    XLabel % Label for plotting, in DICOM coordinate units
    YLabel % Label for plotting, in DICOM coordinate units
    SliceCoordmm % DICOM coordinate of this slice (mm)
    SliceLabel % Label for plotting, in DICOM coordinate units
    SlicePlane % One of sagittal, axial or coronal
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method

    DICOMInfo
    UID % Same as SOPInstanceUID; kept for backwards compatibility
  end
  
  properties (Hidden)
    RescaleSlope = 1; % Used when loading DICOM file to rescale values
    RescaleIntercept = 0; % Used when loading DICOM file to rescale values
  end
  
  methods
    function obj = DICOMImage(Filename, PatientID)
      if nargin == 0
        return;
      end
      
      obj.Filename = Filename;
      
      info = dicominfo(obj.Filename);
      
      if exist('PatientID', 'var') && ~isempty(PatientID)
        obj.PatientID = PatientID;
      else
        obj.PatientID = info.PatientID;
      end

      if isfield(info, 'SeriesDescription')
        obj.SeriesDescription = info.SeriesDescription;
      else
        obj.SeriesDescription = 'No Description';
      end
      obj.SOPInstanceUID = info.SOPInstanceUID;
      obj.SeriesInstanceUID = info.SeriesInstanceUID;
      obj.StudyInstanceUID = info.StudyInstanceUID;
      obj.Time = get_dicom_time(info, '');
      obj.Modality = info.Modality;
      
      try
        % Some DICOM files don't have valid coordinates, in which case, just leave them
        % out
        obj = UpdateSomeCoordinates(obj, info);
      catch er
        if ~strcmp(er.identifier, 'GetImageCoordinates:NoOrientation')
          rethrow(er);
        end
      end
      
      if isfield(info, 'RescaleIntercept')
        obj.RescaleIntercept = info.RescaleIntercept;
      end
      if isfield(info, 'RescaleSlope')
        obj.RescaleSlope = info.RescaleSlope;
      end
    end
    
    function obj = ClearImageCoordinates(obj)
      % Clear image coordinate properties
      % Helpful because, in my earlier version of DICOMDB.CreateFullDatabase, I saved
      % all these coordinates which vastly increased the database size
      
      obj.DICOMCoordsmm = [];
      obj.XCoordmm = [];
      obj.YCoordmm = [];
    end
    
    function value = get.DICOMInfo(obj)
      if isempty(obj.Filename)
        value = [];
      else
        value = dicominfo(obj.Filename);
      end
    end
    
    function value = get.UID(obj)
      value = obj.SOPInstanceUID;
    end
    
    function obj = set.UID(obj, value)
      obj.SOPInstanceUID = value;
    end
  end
end
