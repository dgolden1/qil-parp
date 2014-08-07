classdef DCEMRIImage
  % A DCE-MRI image, which contains an NxMxP stack of NxM images for P time
  % points
  
  % By Daniel Golden (dgolden1 at stanford dot edu) November 2012
  % $Id$
  
  properties
    ImageStack % Registered image stack
    ImageStackUnregistered % Pre-registered image stack
    ImageInfo % DICOM info struct for each slice
    
    DICOMCoordsmm % Struct with fields x, y and z representing coordinates in mm (one of the three should be a scalar)
    XCoordmm % DICOM coordinate of x-axis (mm)
    YCoordmm % DICOM coordinate of y-axis (mm)
    XLabel % Label for plotting, in DICOM coordinate units
    YLabel % Label for plotting, in DICOM coordinate units
    SliceCoordmm % DICOM coordinate of this slice (mm)
    SliceLabel % Label for plotting, in DICOM coordinate units
    SlicePlane % One of sagittal, axial or coronal
    
    StartDatenum % Datenum time of first image
    Time % Time of each slice with respect to StartDatenum
    
    PatientID
    ImageTag % E.g., pre-chemo or post-chemo

    LesionCenter % Approximate center of lesion, in mm
    
    IFKtrans % ImageFeature: Ktrans
    IFKep % ImageFeature: Kep
    IFVe % ImageFeature: Ve
    IFWashIn % ImageFeature: Wash-In
    IFWashOut % ImageFeature: Wash-Out
    IFAUC % ImageFeature: area under contrast curve
    IFPostContrast % ImageFeature: The post-contrast image
    
    PKModel % Stuct with parameters for pharmacokinetic model for each pixel
    
    RegistrationString
  end
  
  properties (Dependent, SetAccess = private)
    % Private access means there is no "set" method
    
    b_IsRegistered
    PatientIDStr % Patient ID as a string
    Size2D % Size of the first two dimensions of ImageStack
    PixelSpacing % Size, in mm, of a pixel
  end
  
  properties (Dependent)
    MyROI % Updates MyROIPrivate and ImageFeature ROIs
  end
  
  properties (Hidden)
    MyROIPrivate % Access via set.MyROI and get.MyROI
  end
  
  methods
    function obj = DCEMRIImage(patient_id, image_tag, image_stack, image_dicom_info, x_mm, y_mm, z_mm, start_datenum, t)
      if nargin == 0
        return;
      end
      
      if size(image_stack, 3) ~= length(t)
        error('Size of 3rd dimension of image_stack must equal length of t');
      end
      if ~length(image_dicom_info) == length(t)
        error('image_dicom_info must have same length as t');
      end
      
      obj.PatientID = patient_id;
      obj.ImageTag = image_tag;
      obj.ImageStack = image_stack;
      obj.ImageInfo = image_dicom_info;
      obj.StartDatenum = start_datenum;
      obj.Time = t;
      
      obj.DICOMCoordsmm.x = x_mm;
      obj.DICOMCoordsmm.y = y_mm;
      obj.DICOMCoordsmm.z = z_mm;
      
      % Set image coords from DICOM coords
      obj = SetImgCoords(obj);
      
      if length(obj.XCoordmm) ~= size(image_stack, 2) || length(obj.YCoordmm) ~= size(image_stack, 1)
        error('Dimension mismatch between image stack and supplied mm coordinates');
      end
    end
    
    function value = get.b_IsRegistered(obj)
      value = ~isempty(obj.ImageStackUnregistered);
    end
    
    function value = get.PatientIDStr(obj)
      value = patient_id_tostr(obj.PatientID);
    end
    
    function value = get.Size2D(obj)
      value = size(obj.ImageStack(:,:,1));
    end
    
    function value = get.PixelSpacing(obj)
      value = abs(diff(obj.XCoordmm(1:2)));
    end
    
    function value = get.MyROI(obj)
      value = obj.MyROIPrivate;
    end
    
    function obj = set.MyROI(obj, value)
      obj.MyROIPrivate = value;
      
      defined_IFs = GetDefinedIFs(obj);
      for kk = 1:length(defined_IFs)
        obj.(defined_IFs{kk}).MyROI = value;
      end
      
    end
  end
    
  methods (Access = protected)
    obj = SetImgCoords(obj) % Set image coordinates from DICOM coordinates
  end
  
  methods (Static)
    % Get DICOM coordinates from image coordinates
    [dicom_x, dicom_y, dicom_z] = GetDICOMCoords(img_x, img_y, img_slice_coord, img_slice_plane)
    obj = CreateFromDICOMDB(dicom_db, varargin)
    CompareAvgKineticCurves(DMI1, DMI2)
  end
end
