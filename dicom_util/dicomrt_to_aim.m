function dicomrt_to_aim(DicomFilename, AimDirectory)
% This function reads a DICOM RTSTRUCT file and writes an XML file
% according to the AIM V3 standard.
% -------------------------------------------------------------------------
% INPUT variable description
%--------------------------------------------------------------------------
% NAME              TYPE        DESCRIPTION
% DicomFilename     DICOM file  Input DICOM RTSTRUCT file
% AimDirectory      dir         Dir to save XML file using AIM_v3 model
%--------------------------------------------------------------------------
% OUTPUT variable description
%--------------------------------------------------------------------------
% none
%--------------------------------------------------------------------------
% SAMPLE FUNCTION CALL
%--------------------------------------------------------------------------
% generate_aim_from_rtstruct('RTSTRUCT.dcm',cd)
%--------------------------------------------------------------------------
% HISTORY
%--------------------------------------------------------------------------
% 20110424 Andre Dekker, creation
% 20110425 Andre Dekker, added point
% 20110426 Andre Dekker, added 3D coordinate support, storing ROIVolume in
% calcuation result
% 20110608 Andre Dekker, major rework after Pat's comments. Split the AIM
% output into multiple outputs (1 per ROI). Added required fields
% like person, image reference, etc. Changed order so that it conforms to
% the AIM XSD. Output now validates against AIM_v3_rv11_XML.xsd
% 
% 20130128 Daniel Golden (dgolden1 at stanford dot edu), various
% modifications to suit my fancy
% $Id$
%--------------------------------------------------------------------------
% KNOWN ISSUES
%--------------------------------------------------------------------------

dh=dicominfo(DicomFilename); % dicomheader

StrSetRoi_n=size(fieldnames(dh.StructureSetROISequence),1); %number of ROIs

% loop over ROIs
for StrSetROI_i=item_list(StrSetRoi_n)
    %create initial docnode
    docNode=create_aim_image_annotation(dh,StrSetROI_i);
    
    %write into docnode aim elements
    create_aim_calculation(docNode,dh,StrSetROI_i);
    create_aim_imaging_observation(docNode,dh,StrSetROI_i);
    create_aim_imaging_reference_collection(docNode,dh,StrSetROI_i);
    create_aim_geometric_shape(docNode,dh,StrSetROI_i);
    create_aim_person(docNode,dh);
    
    %save docNode as XML file using RTSTRUCT UID.ROI_NUMBER
    ImaAnn=docNode.getElementsByTagName('ImageAnnotation').item(0);
    UniIde=ImaAnn.getAttribute('uniqueIdentifier');
    xmlwrite(fullfile(AimDirectory,[char(UniIde),'.xml']),docNode);
end

function docNode=create_aim_image_annotation(dh,StrSetROI_i)
% creates image annotation node and sets its attributes according to
% dicomheader(dh)
docNode=com.mathworks.xml.XMLUtils.createDocument('ImageAnnotation');
Attr =...
    {...
    'xmlns' 'gme://caCORE.caCORE/3.2/edu.northwestern.radiology.AIM';...
    'aimVersion' '3.0';...
    'cagridId' '0';... 
    'codeMeaning' '???';... % ISSUE unsure how to set this attribute
    'codeValue' '???';... % ISSUE undefined attribute
    'codingSchemeDesignator' '???';... % ISSUE undefined attribute
    'name' dh.StructureSetLabel;... % ISSUE not sure this is a DICOM req'd tag
    'dateTime' datestr(datenum([dh.InstanceCreationDate,...
    'T',dh.InstanceCreationTime(1:6)],...
    'yyyymmddTHHMMSS'),'yyyy-mm-ddTHH:MM:SS');...
    'uniqueIdentifier' [dh.SOPInstanceUID,'.',...
    num2str(dh.StructureSetROISequence.(StrSetROI_i{1}).ROINumber)];...
    'xmlns:xsi' 'http://www.w3.org/2001/XMLSchema-instance';...
    'xsi:schemaLocation'...
    'gme://caCORE.caCORE/3.2/edu.northwestern.radiology.AIM AIM_v3_rv11_XML.xsd'
    };
set_attributes(docNode.getDocumentElement,Attr);

function create_aim_calculation(docNode,dh,StrSetROI_i)
% This subfunction adds calculation result ROI Volume
if isfield(dh.StructureSetROISequence.(StrSetROI_i{1}),'ROIVolume')
    
    % Create the calculation collection
    docNode.getDocumentElement...
        .appendChild(docNode.createTextNode(sprintf('\n'))); % line feed
    calcCol=docNode.createElement('calculationCollection');
    docNode.getDocumentElement.appendChild(calcCol);
    
    % set calculation description
    Calc=docNode.createElement('Calculation');
    calcCol.appendChild(Calc);
    Calc_Attr=        {...
        'cagridId' '0';...
        'uid' '???';... % ISSUE unsure how to set this attribute
        'description' 'Volume';...
        'codeValue' '???';... % ISSUE unsure how to set this attribute
        'codeMeaning' '???';... % ISSUE unsure how to set this attribute
        'codingSchemeDesignator' '???'... % ISSUE unsure how to set this attribute
        };
    set_attributes(Calc,Calc_Attr);
    
    % set calculation result definition
    calcResCol=...
        docNode.createElement('calculationResultCollection');
    Calc.appendChild(calcResCol);
    CalcRes=...
        docNode.createElement('CalculationResult');
    calcResCol.appendChild(CalcRes);
    CalcRes_Attr=        {...
        'cagridId' '0';...
        'numberOfDimensions' '1';... % ISSUE unsure how to set this attribute
        'type' 'Scalar';...
        'unitOfMeasure' 'cc'... % ISSUE unsure how to set this attribute
        };
    set_attributes(CalcRes,CalcRes_Attr);
    
    % set calculation data
    calcDataCol=...
        docNode.createElement('calculationDataCollection');
    CalcRes.appendChild(calcDataCol);
    CalcData=...
        docNode.createElement('CalculationData');
    calcDataCol.appendChild(CalcData);
    CalcData_Attr=        {...
        'cagridId' '0';...
        'value' num2str(dh.StructureSetROISequence...
        .(StrSetROI_i{1}).ROIVolume)...
        };
    set_attributes(CalcData,CalcData_Attr);

    % set coordinates
    cooCol=...
        docNode.createElement('coordinateCollection');
    CalcData.appendChild(cooCol);
    Coo=...
        docNode.createElement('Coordinate');
    cooCol.appendChild(Coo);
    Coo_Attr=        {...
        'cagridId' '0';...
        'dimensionIndex' '1';... % ISSUE unsure how to set this attribute
        'position' '1'}; % ISSUE unsure how to set this attribute
    set_attributes(Coo,Coo_Attr);

    % set dimensions
    dimCol=...
        docNode.createElement('dimensionCollection');
    CalcRes.appendChild(dimCol);
    Dim=...
        docNode.createElement('Dimension');
    dimCol.appendChild(Dim);
    Dim_Attr=        {...
        'cagridId' '0';...
        'index' '1';... % ISSUE unsure how to set this attribute
        'size' '1';... % ISSUE unsure how to set this attribute
        'label' '???'}; % ISSUE unsure how to set this attribute
    set_attributes(Dim,Dim_Attr);

    % create  ReferencedGeometricShape collection & element
    refGeoShaCol=...
        docNode.createElement('referencedGeometricShapeCollection');
    Calc.appendChild(refGeoShaCol);
    RefGeoSha=...
        docNode.createElement('ReferencedGeometricShape');
    refGeoShaCol.appendChild(RefGeoSha);
    RefGeoSha_Attr={'cagridId' '0';...
        'referencedShapeIdentifier' num2str(dh.StructureSetROISequence...
        .(StrSetROI_i{1}).ROINumber)};
    set_attributes(RefGeoSha,RefGeoSha_Attr);
end

function create_aim_imaging_observation(docNode,dh,StrSetROI_i)
% This subfunction adds ImagingObservations with the attribute label
% corresponding to the DICOM ROIName

% Create the image observation collection
docNode.getDocumentElement...
    .appendChild(docNode.createTextNode(sprintf('\n'))); % line feed
imaObsCol=docNode.createElement('imagingObservationCollection');
docNode.getDocumentElement.appendChild(imaObsCol);

% set ImageObservation label to ROIName
ImaObs=docNode.createElement('ImagingObservation');
imaObsCol.appendChild(ImaObs);
ImaObs_Attr=        {...
    'cagridId' '0';...
    'codeValue' '???';... % ISSUE unsure how to set this attribute
    'codeMeaning' '???';... % ISSUE unsure how to set this attribute
    'codingSchemeDesignator' '???';... % ISSUE unsure how to set this attribute
    'label' dh.StructureSetROISequence...
    .(StrSetROI_i{1}).ROIName};
set_attributes(ImaObs,ImaObs_Attr);

% set referencedGeometricShape 
refGeoSha=...
    docNode.createElement('referencedGeometricShape');
ImaObs.appendChild(refGeoSha);

% set ReferencedGeometricShape to ROINumber
RefGeoSha=docNode.createElement('ReferencedGeometricShape');
refGeoSha.appendChild(RefGeoSha);
RefGeoSha_Attr={'cagridId' '0';...
    'referencedShapeIdentifier'...
    num2str(dh.StructureSetROISequence...
    .(StrSetROI_i{1}).ROINumber)};
set_attributes(RefGeoSha,RefGeoSha_Attr);

function create_aim_imaging_reference_collection(docNode,dh,StrSetROI_i)

% Create the image reference collection
docNode.getDocumentElement...
    .appendChild(docNode.createTextNode(sprintf('\n'))); % line feed
imaRefCol=docNode.createElement('imageReferenceCollection');
docNode.getDocumentElement.appendChild(imaRefCol);

RefFraOfRefSeq_n=size(fieldnames(dh.ReferencedFrameOfReferenceSequence),1);
for RefFraOfRefSeq_i=item_list(RefFraOfRefSeq_n)

    % check if correct frame of reference UID
    if strcmp(...
            dh.StructureSetROISequence.(StrSetROI_i{1})...
            .ReferencedFrameOfReferenceUID,...
            dh.ReferencedFrameOfReferenceSequence...
            .(RefFraOfRefSeq_i{1}).FrameOfReferenceUID)
        
        % add ImageReference
        ImaRef=docNode.createElement('ImageReference');
        imaRefCol.appendChild(ImaRef);
        ImaRef_Attr=        {...
            'cagridId' '0';...
            'xsi:type'  'DICOMImageReference'};
        set_attributes(ImaRef,ImaRef_Attr);
        
        % add imageStudy
        imaStu=docNode.createElement('imageStudy');
        ImaRef.appendChild(imaStu);
        
        % loop over studies
        RTRefStuSeq_n=size(fieldnames(dh.ReferencedFrameOfReferenceSequence...
            .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence),1);
        for RTRefStuSeq_i=item_list(RTRefStuSeq_n)

            % add ImageStudy
            ImaStu=docNode.createElement('ImageStudy');
            imaStu.appendChild(ImaStu);
            ImaStu_Attr=        {...
                'cagridId' '0';...
                'instanceUID'  dh.ReferencedFrameOfReferenceSequence...
                .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence...
                .(RTRefStuSeq_i{1}).ReferencedSOPInstanceUID;...
                'startDate' '1900-01-01T00:00:00';... % ISSUE Real start date of study unknown
                'startTime' '000000'}; % ISSUEReal start time of study unknown
            set_attributes(ImaStu,ImaStu_Attr);
            
            % add imageSeries
            imaSer=docNode.createElement('imageSeries');
            ImaStu.appendChild(imaSer);
            
            % loop over series
            RTRefSerSeq_n=size(fieldnames(dh.ReferencedFrameOfReferenceSequence...
                .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence...
                .(RTRefStuSeq_i{1}).RTReferencedSeriesSequence),1);
            for RTRefSerSeq_i=item_list(RTRefSerSeq_n)
                
                % add ImageSeries
                ImaSer=docNode.createElement('ImageSeries');
                imaSer.appendChild(ImaSer);
                ImaSer_Attr=        {...
                    'cagridId' '0';...
                    'instanceUID'  dh.ReferencedFrameOfReferenceSequence...
                    .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence...
                    .(RTRefStuSeq_i{1}).RTReferencedSeriesSequence...
                    .(RTRefSerSeq_i{1}).SeriesInstanceUID};
                set_attributes(ImaSer,ImaSer_Attr);
                
                % add imageCollection
                imaCol=docNode.createElement('imageCollection');
                ImaSer.appendChild(imaCol);
                
                % loop over images
                ConImaSeq_n=size(fieldnames(dh.ReferencedFrameOfReferenceSequence...
                    .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence...
                    .(RTRefStuSeq_i{1}).RTReferencedSeriesSequence...
                    .(RTRefSerSeq_i{1}).ContourImageSequence),1);
                for ConImaSeq_i=item_list(ConImaSeq_n)
                    
                    % add Image
                    Ima=docNode.createElement('Image');
                    imaCol.appendChild(Ima);
                    Ima_Attr=        {...
                        'cagridId' '0';...
                        'sopClassUID' dh.ReferencedFrameOfReferenceSequence...
                    .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence...
                    .(RTRefStuSeq_i{1}).RTReferencedSeriesSequence...
                    .(RTRefSerSeq_i{1}).ContourImageSequence...
                    .(ConImaSeq_i{1}).ReferencedSOPClassUID;...
                        'sopInstanceUID'  dh.ReferencedFrameOfReferenceSequence...
                    .(RefFraOfRefSeq_i{1}).RTReferencedStudySequence...
                    .(RTRefStuSeq_i{1}).RTReferencedSeriesSequence...
                    .(RTRefSerSeq_i{1}).ContourImageSequence...
                    .(ConImaSeq_i{1}).ReferencedSOPInstanceUID};
                    set_attributes(Ima,Ima_Attr);
                end % ConImaSeq_i
            end % RTRefSerSeq_i
        end % RTRefStuSeq_i
    end % FrameOfReferenceUID
end % RefFraOfRefSeq_i

function create_aim_geometric_shape(docNode,dh,StrSetROI_i)
% This subfunction adds GeometricShapes with the AIM shapeIdentifier set to
% the DICOM ROINumber

% Create the geometric shape collection
docNode.getDocumentElement...
    .appendChild(docNode.createTextNode(sprintf('\n'))); % line feed
geoShaCol=docNode.createElement('geometricShapeCollection');
docNode.getDocumentElement.appendChild(geoShaCol);


% Determine ROINumber for this ROI
ROINumber=dh.StructureSetROISequence.(StrSetROI_i{1}).ROINumber;
ReferencedFrameOfReferenceUID=...
    dh.StructureSetROISequence.(StrSetROI_i{1})...
    .ReferencedFrameOfReferenceUID;

% Loop over ROIContourSequence to find corresponding ROI
for ROIConSeq_i=item_list(size(fieldnames(dh.ROIContourSequence),1))
    
    % find matching ROINumber in ROIContourSequence
    % and require contour sequence to be present
    if and(ROINumber==...
            dh.ROIContourSequence.(ROIConSeq_i{1}).ReferencedROINumber,...
            isfield(dh.ROIContourSequence.(ROIConSeq_i{1}),...
            'ContourSequence'))
        ConSeq_n=...
            size(fieldnames(dh.ROIContourSequence...
            .(ROIConSeq_i{1}).ContourSequence),1);
        
        % loop over contour sequence (usually image slices, but can be
        % more contours on a single slice)
        % AIM uses coordinateIndex per spatial coordinate of a shape,
        % DICOM uses an index per shape per contoursequence
        coordinateIndex=0;
        for ConSeq_i=item_list(ConSeq_n)
            % If first pass, write GeometricShape
            if strcmp(ConSeq_i{1},'Item_1')
                ROIDisplayColor=...
                    dh.ROIContourSequence.(ROIConSeq_i{1}).ROIDisplayColor;
                ContourGeometricType=...
                    dh.ROIContourSequence.(ROIConSeq_i{1})...
                    .ContourSequence.(ConSeq_i{1}).ContourGeometricType;
                
                % write Geometric Shape Attribute
                GeoSha_Attr=        {...
                    'cagridId' '0';...
                    'includeFlag' 'true';...
                    'lineColor' num2str(ROIDisplayColor');... 
                    'shapeIdentifier' num2str(ROINumber);...
                    };
                switch ContourGeometricType
                    case 'CLOSED_PLANAR'
                        GeoSha_Attr=...
                            [GeoSha_Attr;{'xsi:type' 'Polyline'}];
                    case 'POINT'
                        GeoSha_Attr=...
                            [GeoSha_Attr;{'xsi:type' 'Point'}];
                    otherwise
                        break
                end
                GeoSha=docNode.createElement('GeometricShape');
                geoShaCol.appendChild(GeoSha);
                set_attributes(GeoSha,GeoSha_Attr);
                
                % create spatialCoordinateCollection to store
                % coordinates
                spaCooCol=docNode...
                    .createElement('spatialCoordinateCollection');
                GeoSha.appendChild(spaCooCol);
            end
            
            NumberOfContourPoints=...
                dh.ROIContourSequence.(ROIConSeq_i{1})...
                .ContourSequence.(ConSeq_i{1}).NumberOfContourPoints;
            for ContourPoint_Index=1:NumberOfContourPoints
                disp_string=['Point ',num2str(ContourPoint_Index),' of ',...
                    num2str(NumberOfContourPoints),' of ',...
                    'ContourSequence ',ConSeq_i{1},' of ',...
                    num2str(ConSeq_n),...
                    ];
                if ContourPoint_Index==1,disp(disp_string)
                else
                    disp([char(8)*ones(1,lStr+1),disp_string]);
                end
                lStr = length(disp_string);
                
                x_index=1+3*(ContourPoint_Index-1);
                y_index=2+3*(ContourPoint_Index-1);
                z_index=3+3*(ContourPoint_Index-1);
                x=dh.ROIContourSequence.(ROIConSeq_i{1})...
                    .ContourSequence.(ConSeq_i{1})...
                    .ContourData(x_index);
                y=dh.ROIContourSequence.(ROIConSeq_i{1})...
                    .ContourSequence.(ConSeq_i{1})...
                    .ContourData(y_index);
                z=dh.ROIContourSequence.(ROIConSeq_i{1})...
                    .ContourSequence.(ConSeq_i{1})...
                    .ContourData(z_index);
                switch isfield(dh.ROIContourSequence.(ROIConSeq_i{1})...
                        .ContourSequence.(ConSeq_i{1}),...
                        'ContourImageSequence')
                    case true % 2D coordinate linked to SOP Instance UID
                        ReferencedSOPInstanceUID=...
                            dh.ROIContourSequence.(ROIConSeq_i{1})...
                            .ContourSequence.(ConSeq_i{1}).ContourImageSequence...
                            .Item_1... % ISSUE this assumes only one SOPInstance is used in this contour
                            .ReferencedSOPInstanceUID;
                        SpaCoo_Attr={...
                            'cagridId' '0';...
                            'coordinateIndex' num2str(coordinateIndex);...
                            'xsi:type' 'TwoDimensionSpatialCoordinate';...
                            'imageReferenceUID' ReferencedSOPInstanceUID;...
                            'referencedFrameNumber' '1';... % ISSUE only single fram images assumed
                            'x' num2str(x);...
                            'y' num2str(y)...
                            };
                    case false % 3D coordinate
                        SpaCoo_Attr={...
                            'cagridId' '0';...
                            'coordinateIndex' num2str(coordinateIndex);...
                            'xsi:type' 'ThreeDimensionSpatialCoordinate';...
                            'frameOfReferenceUID' ReferencedFrameOfReferenceUID;... % ISSUE what is the role of this frameOfReferenceUID, not sure if this is correct
                            'x' num2str(x);...
                            'y' num2str(y);...
                            'z' num2str(z)...
                            };
                end
                SpaCoo=docNode.createElement('SpatialCoordinate');
                spaCooCol.appendChild(SpaCoo);
                set_attributes(SpaCoo,SpaCoo_Attr);
                coordinateIndex=coordinateIndex+1;
            end %contour points
        end %ContourSequence
    end %ROINumber
end %ROIContourSequence

function create_aim_person(docNode,dh)
% Create the person element
docNode.getDocumentElement...
    .appendChild(docNode.createTextNode(sprintf('\n'))); % line feed
per=docNode.createElement('person');
docNode.getDocumentElement.appendChild(per);

% add Person entry
Per=docNode.createElement('Person');
per.appendChild(Per);
Per_Attr=        {...
    'cagridId' '0';...
    'name'  dh.PatientName.FamilyName;...
    'id'  dh.PatientID};
set_attributes(Per,Per_Attr);

% --- COMMON SUBFUNCTION
function set_attributes(Element,Attributes)
% subfunction that writes a cell of Attributes to Element
for Attribute_Index=1:size(Attributes,1)
    if ~isempty(Attributes{Attribute_Index,2})
        Element.setAttribute(...
            Attributes{Attribute_Index,1},Attributes{Attribute_Index,2});
    end
end

function ItemList =item_list(Length)
% This function creates an Item_1..Item_N list
ItemList = [];
for Item_Ind=1:Length
    ItemList=[ItemList {['Item_',num2str(Item_Ind)]}];
end
