function varargout = roi_gui(varargin)
% ROI_GUI MATLAB code for roi_gui.fig
%      ROI_GUI, by itself, creates a new ROI_GUI or raises the existing
%      singleton*.
%
%      H = ROI_GUI returns the handle to a new ROI_GUI or the handle to
%      the existing singleton*.
%
%      ROI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_GUI.M with the given input arguments.
%
%      ROI_GUI('Property','Value',...) creates a new ROI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before roi_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to roi_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help roi_gui

% Last Modified by GUIDE v2.5 17-Sep-2012 13:03:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @roi_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @roi_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before roi_gui is made visible.
function roi_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to roi_gui (see VARARGIN)

% Choose default command line output for roi_gui
handles.output = hObject;

handles.userdata.patient_id = varargin{1};
handles.userdata.pre_or_post_chemo = varargin{2};

% Load patient data
slice_filename = get_slice_filename(handles.userdata.patient_id, handles.userdata.pre_or_post_chemo);
load(slice_filename);

% Get and plot lesion center
[handles.userdata.x_coord_mm, handles.userdata.y_coord_mm, x_label, y_label, slice_location_mm, slice_label] = get_img_coords(x_mm, y_mm, z_mm);

spreadsheet_values = get_spreadsheet_info(patient_id);

if strcmp(str_pre_or_post_chemo, 'pre')
  lesion_center_mm = [spreadsheet_values.x_mm, spreadsheet_values.y_mm, spreadsheet_values.z_mm];
else
  lesion_center_mm = [spreadsheet_values.x_mm_post, spreadsheet_values.y_mm_post, spreadsheet_values.z_mm_post];
end

if strcmpi(spreadsheet_values.slice_plane, 'sagittal')
  handles.userdata.lesion_center_xy = lesion_center_mm(2:3);
elseif strcmpi(spreadsheet_values.slice_plane, 'axial')
  handles.userdata.lesion_center_xy = lesion_center_mm(1:2);
else
  error('No slice plane specified for patient %d', patient_id);
end

% Mask out a region within 30 pixels of the lesion center to determine
% color limits
handles.userdata.contrast_mask = false(size(slices(:,:,1)));
[img_X, img_Y] = meshgrid(x_coord_mm, y_coord_mm);
handles.userdata.contrast_mask(sqrt((img_X - lesion_center_xy(1)).^2 + (img_Y - lesion_center_xy(2)).^2) < 30) = true;

% Make empirical map
t_map_start = now;

plot_empirical_kinetic_map(slices, x_mm, y_mm, z_mm, t, info, 'contrast_mask', contrast_mask, 'h_ax', h_ax);
fprintf('Plotted kinetic map in %s\n', time_elapsed(t_map_start, now));
title(sprintf('Emperical kinetic map  patient %d  %s=%0.1f mm', patient_id, slice_label, slice_location_mm));

% Show lesion center
if exist('patient_id', 'var') && ~isempty(patient_id)
  hold on;
  h_marker = plot(lesion_center_xy(1), lesion_center_xy(2), 'o', 'markersize', 14, 'markeredgecolor', [1 1 1], 'markerfacecolor', [1 0 1]);
end


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes roi_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = roi_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% % Get default command line output from handles structure
% varargout{1} = handles.output;

varargout{1} = findobj(0, 'Tag', 'axes_roi_gui');


% --- Executes on button press in pushbutton_get_roi.
function pushbutton_get_roi_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_get_roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_ax = findobj(0, 'Tag', 'axes_roi_gui');
handles.userdata.roi_poly = roi_select_points(h_ax);

% Mask ROI
% Get ROI in pixels (not necessarily rounded); necessary for poly2mask function
[x_roi_px, y_roi_px] = roi_mm_to_px(handles.userdata.x_coord_mm, handles.userdata.y_coord_mm, ...
  handles.userdata.roi_poly.img_x_mm, handles.userdata.roi_poly.img_y_mm);
roi_mask = poly2mask(x_roi_px, y_roi_px, size(slices, 1), size(slices, 2));

% --- Executes on button press in pushbutton_no_lesion.
function pushbutton_no_lesion_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_no_lesion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function axes_roi_gui_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes_roi_gui (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes_roi_gui
