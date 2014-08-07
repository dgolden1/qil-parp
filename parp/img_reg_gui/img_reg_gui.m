function varargout = img_reg_gui(varargin)
% IMG_REG_GUI MATLAB code for img_reg_gui.fig
%      IMG_REG_GUI, by itself, creates a new IMG_REG_GUI or raises the existing
%      singleton*.
%
%      H = IMG_REG_GUI returns the handle to a new IMG_REG_GUI or the handle to
%      the existing singleton*.
%
%      IMG_REG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IMG_REG_GUI.M with the given input arguments.
%
%      IMG_REG_GUI('Property','Value',...) creates a new IMG_REG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before img_reg_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to img_reg_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help img_reg_gui

% Last Modified by GUIDE v2.5 20-Sep-2012 14:10:01
% $Id$

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @img_reg_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @img_reg_gui_OutputFcn, ...
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


% --- Executes just before img_reg_gui is made visible.
function img_reg_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to img_reg_gui (see VARARGIN)

% Choose default command line output for img_reg_gui
handles.output = hObject;

% UIWAIT makes img_reg_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Create patient ID dropdown list
addpath(fullfile(qilsoftwareroot, 'parp'));
handles = set_patient_id_popup(handles);

% Set default optimizer values
set_optimizer_defaults(handles);

% Link before and after axes
linkaxes([handles.axes_before, handles.axes_after]);

% Update handles structure
guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = img_reg_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function str_pre_or_post_chemo = get_str_pre_or_post_chemo(handles)
% Get a string describing whether we're dealing with pre or post chemo data

if get(handles.radiobutton_pre_chemo, 'Value')
  str_pre_or_post_chemo = 'pre';
elseif get(handles.radiobutton_post_chemo, 'Value')
  str_pre_or_post_chemo = 'post';
end


function zoom_to_lesion(handles)

if get(handles.checkbox_zoom, 'Value') && ~isempty(handles.patientdata.crop_x)
  axis([handles.patientdata.crop_x(:); handles.patientdata.crop_y(:)].');
end



function [translate_x, translate_y, rotate_ccw_deg] = get_custom_matrix(handles)
% Read the custom matrix values

translate_x = str2double(get(handles.edit_translate_x, 'String'));
translate_y = str2double(get(handles.edit_translate_y, 'String'));
rotate_ccw_deg = str2double(get(handles.edit_rotate_ccw, 'String'));

function handles = set_custom_matrix(handles, translate_x, translate_y, rotate_ccw_deg)
% Set the custom matrix values

set(handles.edit_translate_x, 'String', num2str(translate_x, '%G'));
set(handles.edit_translate_y, 'String', num2str(translate_y, '%G'));
set(handles.edit_rotate_ccw, 'String', num2str(rotate_ccw_deg, '%G'));

function handles = set_patient_id_popup(handles)
% Create the patient ID popup

str_pre_or_post_chemo = get_str_pre_or_post_chemo(handles);

handles.parpdb = PARPDB(str_pre_or_post_chemo);

handles.patientdata.patient_ids = GetPatientList(handles.parpdb);
listbox_str{1} = 'Select';

for kk = 1:length(handles.patientdata.patient_ids)
  % NOTE: this will be very slow because we have to load each PARPDCEMRIImage in full. I
  % should try to speed this up by, e.g., saving just the fields of the PDMI objects and
  % loading individual fields instead of the full file
  
  this_patient_id = handles.patientdata.patient_ids(kk);
  pdmi_filename = GetPatientFilenameFromID(handles.parpdb, this_patient_id);
  load(pdmi_filename, 'DEPENDENT_b_IsRegistered', 'RegistrationString');
  
  if DEPENDENT_b_IsRegistered
    listbox_str{end+1} = sprintf('%03d %s', this_patient_id, RegistrationString);
  else
    listbox_str{end+1} = sprintf('%03d unreg', this_patient_id);
  end
end

set(handles.popupmenu_patient_id, 'String', listbox_str);



function handles = delete_crop_rectangle(handles)

% Delete old drawn rectangle
if isfield(handles.patientdata, 'h_rect1') && ~isempty(handles.patientdata.h_rect1) && ishandle(handles.patientdata.h_rect1)
  delete(handles.patientdata.h_rect1);
end

handles.patientdata.crop_x = get(handles.axes_before, 'xlim');
handles.patientdata.crop_y = get(handles.axes_before, 'ylim');


function patient_id = get_patient_id(handles)
% Get patient ID from figure

selection = get(handles.popupmenu_patient_id, 'Value');
if selection == 1 % Chose no patient
  patient_id = nan;
else
  patient_id = handles.patientdata.patient_ids(selection - 1); % 'Select' is the first selection
end


function handles = plot_new_image_pair(handles, idx, b_keep_crop)
% Plot a new pair of images

set_image_info(handles, handles.PDMI.Time, idx);

title_str = sprintf('t=%0.0f (Green) vs t=%0.0f (Magenta) Original', handles.PDMI.Time(idx(1)), handles.PDMI.Time(idx(2)));
plot_img_diff(handles.PDMI.ImageStack(:,:,idx(1)), handles.PDMI.ImageStackUnregistered(:,:,idx(2)), ...
  title_str, handles.PDMI, handles.axes_before);
increase_font(handles.axes_before);

% Plot registered image
if isequal(handles.PDMI.ImageStack(:,:,idx(2)), handles.PDMI.ImageStackUnregistered(:,:,idx(2)))
  title_str = 'Not yet registered';
else
  title_str = 'Registered';
end
plot_img_diff(handles.PDMI.ImageStack(:,:,idx(1)), handles.PDMI.ImageStack(:,:,idx(2)), ...
  title_str, handles.PDMI, handles.axes_after);
increase_font(handles.axes_after);

if ~b_keep_crop
  % Clear crop rectangle
  handles = delete_crop_rectangle(handles);
elseif ~isempty(handles.patientdata.crop_x) && get(handles.checkbox_zoom, 'Value')
  % Re-zoom
  axis([handles.patientdata.crop_x(:); handles.patientdata.crop_y(:)].');
end

% Set slider
set(handles.slider_img_num, 'SliderStep', 1/(length(handles.PDMI.Time) - 2)*[1 5]);
set(handles.slider_img_num, 'Value', (idx(2) - 2)/(length(handles.PDMI.Time) - 2));

function set_image_info(handles, t, idx)
% Update some GUI text about what images are loaded

set(handles.edit_fixed_idx, 'String', num2str(idx(1), '%d'));
set(handles.edit_moving_idx, 'String', num2str(idx(2), '%d'));
set(handles.edit_fixed_t, 'String', sprintf('t=%0.0f', t(idx(1))));
set(handles.edit_moving_t, 'String', sprintf('t=%0.0f', t(idx(2))));
set(handles.text_img_info, 'String', sprintf('%d images', length(t)));

function [optimizer, metric] = get_imregconfig(handles)
% Create optimizer based on GUI values

if get(handles.checkbox_multimodal, 'Value')
  [optimizer, metric] = imregconfig('multimodal');
  
  optimizer.GrowthFactor = str2double(get(handles.edit_MultiGrowFactor, 'String'));
  optimizer.Epsilon = str2double(get(handles.edit_MultiEpsilon, 'String'));
  optimizer.InitialRadius = str2double(get(handles.edit_MultiInitRadius, 'String'));
  optimizer.MaximumIterations = str2double(get(handles.edit_MultiMaxIter, 'String'));
else
  [optimizer, metric] = imregconfig('monomodal');
  
  optimizer.GradientMagnitudeTolerance = str2double(get(handles.edit_MonoGradMagTol, 'String'));
  optimizer.MinimumStepLength = str2double(get(handles.edit_MonoMinStepLen, 'String'));
  optimizer.MaximumStepLength = str2double(get(handles.edit_MonoMaxStepLen, 'String'));
  optimizer.MaximumIterations = str2double(get(handles.edit_MonoMaxIter, 'String'));
  optimizer.RelaxationFactor = str2double(get(handles.edit_MonoRelaxFact, 'String'));
end


function idx = get_img_idx(handles)
% Get indices of moving and fixed slices

idx(1) = str2double(get(handles.edit_fixed_idx, 'String'));
idx(2) = str2double(get(handles.edit_moving_idx, 'String'));


function set_optimizer_defaults(handles)
% Set all the optimizer twiddle values to their defaults

%% Set multimodal defaults
[optimizer, metric] = imregconfig('multimodal');

set(handles.edit_MultiGrowFactor, 'String', num2str(optimizer.GrowthFactor, '%G'));
set(handles.edit_MultiEpsilon, 'String', num2str(optimizer.Epsilon, '%G'));
set(handles.edit_MultiInitRadius, 'String', num2str(optimizer.InitialRadius, '%G'));
set(handles.edit_MultiMaxIter, 'String', num2str(optimizer.MaximumIterations, '%G'));


%% Set monomodal defaults
[optimizer, metric] = imregconfig('monomodal');

set(handles.edit_MonoGradMagTol, 'String', num2str(optimizer.GradientMagnitudeTolerance, '%G'));
set(handles.edit_MonoMinStepLen, 'String', num2str(optimizer.MinimumStepLength, '%G'));
set(handles.edit_MonoMaxStepLen, 'String', num2str(optimizer.MaximumStepLength, '%G'));
set(handles.edit_MonoMaxIter, 'String', num2str(optimizer.MaximumIterations, '%G'));
set(handles.edit_MonoRelaxFact, 'String', num2str(optimizer.RelaxationFactor, '%G'));

%% Set custom matrix defaults
set_custom_matrix(handles, 0, 0, 0);


% --- Executes on selection change in popupmenu_patient_id.
function popupmenu_patient_id_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_patient_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_patient_id contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_patient_id

patient_id = get_patient_id(handles);
if isnan(patient_id)
  return;
end

str_pre_or_post_chemo = get_str_pre_or_post_chemo(handles);
if isnan(patient_id)
  handles.PDMI = [];
  return;
else
  handles.PDMI = GetPatientImage(handles.parpdb, patient_id);
  
  if isempty(handles.PDMI.ImageStackUnregistered)
    handles.PDMI.ImageStackUnregistered = handles.PDMI.ImageStack;
  end
end

handles.patientdata.crop_x = [];
handles.patientdata.crop_y = [];

% Plot first two images in 'before' axes
idx = [1 2];
handles = plot_new_image_pair(handles, idx, false);

set(handles.text_messages, 'String', '');

guidata(hObject, handles); % Update handles structure


% --- Executes during object creation, after setting all properties.
function popupmenu_patient_id_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_patient_id (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MonoGradMagTol_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MonoGradMagTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MonoGradMagTol as text
%        str2double(get(hObject,'String')) returns contents of edit_MonoGradMagTol as a double


% --- Executes during object creation, after setting all properties.
function edit_MonoGradMagTol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MonoGradMagTol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MonoMinStepLen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MonoMinStepLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MonoMinStepLen as text
%        str2double(get(hObject,'String')) returns contents of edit_MonoMinStepLen as a double


% --- Executes during object creation, after setting all properties.
function edit_MonoMinStepLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MonoMinStepLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MonoMaxStepLen_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MonoMaxStepLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MonoMaxStepLen as text
%        str2double(get(hObject,'String')) returns contents of edit_MonoMaxStepLen as a double


% --- Executes during object creation, after setting all properties.
function edit_MonoMaxStepLen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MonoMaxStepLen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MonoMaxIter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MonoMaxIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MonoMaxIter as text
%        str2double(get(hObject,'String')) returns contents of edit_MonoMaxIter as a double


% --- Executes during object creation, after setting all properties.
function edit_MonoMaxIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MonoMaxIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MonoRelaxFact_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MonoRelaxFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MonoRelaxFact as text
%        str2double(get(hObject,'String')) returns contents of edit_MonoRelaxFact as a double


% --- Executes during object creation, after setting all properties.
function edit_MonoRelaxFact_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MonoRelaxFact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MultiGrowFactor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MultiGrowFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MultiGrowFactor as text
%        str2double(get(hObject,'String')) returns contents of edit_MultiGrowFactor as a double


% --- Executes during object creation, after setting all properties.
function edit_MultiGrowFactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MultiGrowFactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MultiEpsilon_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MultiEpsilon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MultiEpsilon as text
%        str2double(get(hObject,'String')) returns contents of edit_MultiEpsilon as a double


% --- Executes during object creation, after setting all properties.
function edit_MultiEpsilon_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MultiEpsilon (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MultiInitRadius_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MultiInitRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MultiInitRadius as text
%        str2double(get(hObject,'String')) returns contents of edit_MultiInitRadius as a double


% --- Executes during object creation, after setting all properties.
function edit_MultiInitRadius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MultiInitRadius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_MultiMaxIter_Callback(hObject, eventdata, handles)
% hObject    handle to edit_MultiMaxIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_MultiMaxIter as text
%        str2double(get(hObject,'String')) returns contents of edit_MultiMaxIter as a double


% --- Executes during object creation, after setting all properties.
function edit_MultiMaxIter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_MultiMaxIter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_register.
function pushbutton_register_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_register (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = get_img_idx(handles);
fixed_full = handles.PDMI.ImageStack(:,:,idx(1));
moving_full = handles.PDMI.ImageStackUnregistered(:,:,idx(2));

crop_x = handles.patientdata.crop_x;
crop_y = handles.patientdata.crop_x;

if isempty(crop_x)
  crop_x = [1 size(fixed_full, 2)];
  crop_y = [1 size(fixed_full, 1)];
end

if get(handles.checkbox_custom_matrix, 'Value')
  [translate_x, translate_y, rotate_ccw_deg] = get_custom_matrix(handles);
  % For transformation matrix formula, see http://en.wikipedia.org/wiki/Transformation_matrix#Affine_transformations
  tform_matrix = [cos(rotate_ccw_deg*pi/180), -sin(rotate_ccw_deg*pi/180), 0;
                  sin(rotate_ccw_deg*pi/180), cos(rotate_ccw_deg*pi/180), 0;
                  translate_x, translate_y, 1];
  tform = maketform('affine', tform_matrix);

  % Set coordinate origin to middle of croped window
  if ~isempty(handles.patientdata.crop_x)
    tform_xcoords = [1 size(fixed_full, 2)] - mean(handles.patientdata.crop_x) + 1;
    tform_ycoords = [1 size(fixed_full, 1)] - mean(handles.patientdata.crop_y) + 1;
  else
    tform_xcoords = [1 size(fixed_full, 2)];
    tform_ycoords = [1 size(fixed_full, 1)];
  end
  
  moving_registered = imtransform(moving_full, tform, 'UData', tform_xcoords, 'VData', tform_ycoords, ...
    'XData', tform_xcoords, 'YData', tform_ycoords);
else
  [optimizer, metric] = get_imregconfig(handles);
  [moving_registered, tform, tform_xcoords, tform_ycoords] = register_image_intensity(moving_full, fixed_full, ...
    'sub_img_x_lim', crop_x, 'sub_img_y_lim', crop_y, 'optimizer', optimizer, 'metric', metric);
end

title_str = 'Registered';
plot_img_diff(fixed_full, moving_registered, title_str, handles.PDMI, handles.axes_after);
increase_font(handles.axes_after);
if get(handles.checkbox_zoom, 'Value')
  axis([handles.patientdata.crop_x(:); handles.patientdata.crop_y(:)].');
end


% Save registered slice
handles.PDMI.ImageStack(:,:,idx(2)) = moving_registered;

% Apply transform to all subsequent slices
for kk = (idx(2) + 1):length(handles.PDMI.Time)
  this_idx = kk;
  handles.PDMI.ImageStack(:,:,this_idx) = imtransform(handles.PDMI.ImageStackUnregistered(:,:,this_idx), ...
    tform, 'UData', tform_xcoords, 'VData', tform_ycoords, 'XData', tform_xcoords, 'YData', tform_ycoords, 'XYScale', 1);
end

set(handles.text_messages, 'String', 'There are unsaved changes');

guidata(hObject, handles); % Update handles structure

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.PDMI.RegistrationString = sprintf('registered %s', datestr(now, 31));
AddToDB(handles.parpdb, handles.PDMI);

set(handles.text_messages, 'String', '');

% --- Executes on button press in pushbutton_prev.
function pushbutton_prev_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_prev (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = get_img_idx(handles);

if idx(2) > 2
  if get(handles.checkbox_hold_fixed, 'Value')
    new_idx = [idx(1), idx(2)-1];
  else
    new_idx = [idx(2)-2, idx(2)-1];
  end
  handles = plot_new_image_pair(handles, new_idx, true);
  guidata(hObject, handles); % Update handles structure
else
  fprintf('Already at first image\n');
end


% --- Executes on button press in pushbutton_next.
function pushbutton_next_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = get_img_idx(handles);

if idx(2) < length(handles.PDMI.Time);
  if get(handles.checkbox_hold_fixed, 'Value')
    new_idx = [idx(1), idx(2)+1];
  else
    new_idx = [idx(2), idx(2)+1];
  end
  handles = plot_new_image_pair(handles, new_idx, true);
  guidata(hObject, handles); % Update handles structure
else
  fprintf('Already at last image (%d)\n', idx(2));
end



% --- Executes on button press in pushbutton_crop.
function pushbutton_crop_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_crop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes_before);
[x, y] = ginput(2);

if length(x) < 2
  % User quit; don't crop
  return;
end

% Delete old drawn rectangle
if isfield(handles.patientdata, 'h_rect1') && ~isempty(handles.patientdata.h_rect1) && ishandle(handles.patientdata.h_rect1)
  handles = delete_crop_rectangle(handles);
end

handles.patientdata.crop_x = round(sort(x));
handles.patientdata.crop_y = round(sort(y));

handles.patientdata.h_rect1 = plot_rectangle(handles.axes_before, x, y);

zoom_to_lesion(handles);

guidata(hObject, handles); % Update handles structure

% --- Executes on button press in checkbox_zoom.
function checkbox_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_zoom

saxes(handles.axes_before);

if ~isempty(handles.patientdata.crop_x) && get(handles.checkbox_zoom, 'Value')
  axis([handles.patientdata.crop_x(:); handles.patientdata.crop_y(:)].');
elseif ~get(handles.checkbox_zoom, 'Value')
  h_img = findobj(handles.axes_before, 'type', 'image');
  set(gca, 'xlim', get(h_img, 'XData'), 'ylim', get(h_img, 'YData'));
end



function edit_fixed_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fixed_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fixed_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_fixed_idx as a double

idx = get_img_idx(handles);
handles = plot_new_image_pair(handles, idx, true);
guidata(hObject, handles); % Update handles structure



% --- Executes during object creation, after setting all properties.
function edit_fixed_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fixed_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_moving_idx_Callback(hObject, eventdata, handles)
% hObject    handle to edit_moving_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_moving_idx as text
%        str2double(get(hObject,'String')) returns contents of edit_moving_idx as a double

idx = get_img_idx(handles);
handles = plot_new_image_pair(handles, idx, true);
guidata(hObject, handles); % Update handles structure


% --- Executes during object creation, after setting all properties.
function edit_moving_idx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_moving_idx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_monomodal.
function checkbox_monomodal_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_monomodal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_monomodal

if get(handles.checkbox_monomodal, 'Value')
  set(handles.checkbox_multimodal, 'Value', false);
  set(handles.checkbox_custom_matrix, 'Value', false);
end


% --- Executes on button press in checkbox_multimodal.
function checkbox_multimodal_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_multimodal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_multimodal

if get(handles.checkbox_multimodal, 'Value')
  set(handles.checkbox_monomodal, 'Value', false);
  set(handles.checkbox_custom_matrix, 'Value', false);
end


function edit_fixed_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_fixed_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_fixed_t as text
%        str2double(get(hObject,'String')) returns contents of edit_fixed_t as a double


% --- Executes during object creation, after setting all properties.
function edit_fixed_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_fixed_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_moving_t_Callback(hObject, eventdata, handles)
% hObject    handle to edit_moving_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_moving_t as text
%        str2double(get(hObject,'String')) returns contents of edit_moving_t as a double


% --- Executes during object creation, after setting all properties.
function edit_moving_t_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_moving_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider_img_num_Callback(hObject, eventdata, handles)
% hObject    handle to slider_img_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

idx_old = get_img_idx(handles);
idx(2) = round(get(handles.slider_img_num, 'Value')*(length(handles.PDMI.Time) - 2) + 2);

if get(handles.checkbox_hold_fixed, 'Value')
  idx(1) = min(idx_old(1), idx(2) - 1);
else
  idx(1) = idx(2) - 1;
end

handles = plot_new_image_pair(handles, idx, true);

guidata(hObject, handles); % Update handles structure

% --- Executes during object creation, after setting all properties.
function slider_img_num_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_img_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton_revert.
function pushbutton_revert_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_revert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.text_messages, 'String', '');

guidata(hObject, handles); % Update handles structure

popupmenu_patient_id_Callback(handles.popupmenu_patient_id, eventdata, handles);


% --- Executes on button press in pushbutton_next_patient.
function pushbutton_next_patient_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_next_patient (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

b_unsaved_changes = ~strcmp('', get(handles.text_messages, 'String'));
if b_unsaved_changes
  errordlg('Please save or revert changes');
  return;
end

numvals = length(get(handles.popupmenu_patient_id, 'String'));
thisval = get(handles.popupmenu_patient_id, 'Value');
if thisval < numvals
  set(handles.popupmenu_patient_id, 'Value', thisval + 1);
  popupmenu_patient_id_Callback(handles.popupmenu_patient_id, eventdata, handles);
end


% --- Executes on key press with focus on edit_MonoMaxIter and none of its controls.
function edit_MonoMaxIter_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to edit_MonoMaxIter (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton_reset_optimizer.
function pushbutton_reset_optimizer_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset_optimizer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set_optimizer_defaults(handles);


% --- Executes on mouse press over axes background.
function axes_before_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes_before (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

switch eventdata.Key
  case 'm'
    pan(handles.axes_before, 'on');
  case 'z'
    zoom(handles.axes_before, 'on');
  case 'n'
    pushbutton_next_Callback(handles.pushbutton_next, eventdata, handles);
  case 'p'
    pushbutton_prev_Callback(handles.pushbutton_prev, eventdata, handles);
  case {'rightarrow', 'downarrow', 'leftarrow', 'uparrow'}
    [translate_x, translate_y, rotate_ccw_deg] = get_custom_matrix(handles);
    
    if isempty(eventdata.Modifier)
      switch eventdata.Key
        case 'rightarrow'
          translate_x = translate_x + 0.25;
        case 'downarrow'
          translate_y = translate_y + 0.25;
        case 'leftarrow'
          translate_x = translate_x - 0.25;
        case 'uparrow'
          translate_y = translate_y - 0.25;
      end    
    elseif isequal(eventdata.Modifier, {'command'})
      switch eventdata.Key
        case 'rightarrow'
          rotate_ccw_deg = rotate_ccw_deg - 1;
        case 'leftarrow'
          rotate_ccw_deg = rotate_ccw_deg + 1;
      end
    else
      return;
    end
    
    set_custom_matrix(handles, translate_x, translate_y, rotate_ccw_deg);
  case 'r'
    if isequal(eventdata.Modifier, {'command'})
      pushbutton_register_Callback(handles.pushbutton_register, eventdata, handles);
    end
  case 'f'
    if isequal(eventdata.Modifier, {'command'})
      pushbutton_flash_before_after_Callback(handles.pushbutton_flash_before_after, [], handles);
    end
  case 's'
    if isequal(eventdata.Modifier, {'command'})
      pushbutton_save_Callback(handles.pushbutton_save, [], handles);
    end
end


% --- Executes on button press in pushbutton_zoom.
function pushbutton_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

zoom(handles.axes_before, 'on');

% --- Executes on button press in pushbutton_pan.
function pushbutton_pan_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

pan(handles.axes_before, 'on');


% --- Executes on button press in checkbox_custom_matrix.
function checkbox_custom_matrix_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_custom_matrix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_custom_matrix

if get(handles.checkbox_custom_matrix, 'Value')
  set(handles.checkbox_multimodal, 'Value', false);
  set(handles.checkbox_monomodal, 'Value', false);
end



function edit_translate_x_Callback(hObject, eventdata, handles)
% hObject    handle to edit_translate_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_translate_x as text
%        str2double(get(hObject,'String')) returns contents of edit_translate_x as a double


% --- Executes during object creation, after setting all properties.
function edit_translate_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_translate_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_translate_y_Callback(hObject, eventdata, handles)
% hObject    handle to edit_translate_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_translate_y as text
%        str2double(get(hObject,'String')) returns contents of edit_translate_y as a double


% --- Executes during object creation, after setting all properties.
function edit_translate_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_translate_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_rotate_ccw_Callback(hObject, eventdata, handles)
% hObject    handle to edit_rotate_ccw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_rotate_ccw as text
%        str2double(get(hObject,'String')) returns contents of edit_rotate_ccw as a double


% --- Executes during object creation, after setting all properties.
function edit_rotate_ccw_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_rotate_ccw (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_flash_before_after.
function pushbutton_flash_before_after_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_flash_before_after (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = get_img_idx(handles);

colormap gray;
pause_time = 0.3;
num_reps = 3;

text_x = mean(handles.patientdata.crop_x);
text_y = mean(handles.patientdata.crop_y);

for kk = 1:num_reps
  % Show earlier registered image
  saxes(handles.axes_before);
  imagesc(handles.PDMI.ImageStack(:,:,idx(1)));
  text(text_x, text_y, 'Before Registered', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold', 'horizontalalignment', 'center');
  axis equal tight off

  saxes(handles.axes_after);
  imagesc(handles.PDMI.ImageStack(:,:,idx(1)));
  text(text_x, text_y, 'Before Registered', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold', 'horizontalalignment', 'center');
  axis equal tight off
  zoom_to_lesion(handles);

  pause(pause_time);

  % Show later unregistered and registered image
  saxes(handles.axes_before);
  imagesc(handles.PDMI.ImageStackUnregistered(:,:,idx(2)));
  text(text_x, text_y, 'After Unregistered', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold', 'horizontalalignment', 'center');
  axis equal tight off

  saxes(handles.axes_after);
  imagesc(handles.PDMI.ImageStack(:,:,idx(2)));
  text(text_x, text_y, 'After Registered', 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold', 'horizontalalignment', 'center');
  axis equal tight off
  zoom_to_lesion(handles);

  pause(pause_time);
end

% Return to imshowpair image
handles = plot_new_image_pair(handles, idx, true);
zoom_to_lesion(handles);
handles.patientdata.h_rect1 = plot_rectangle(handles.axes_before, handles.patientdata.crop_x, handles.patientdata.crop_y);

guidata(hObject, handles); % Update handles structure


% --- Executes on button press in checkbox_hold_fixed.
function checkbox_hold_fixed_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_hold_fixed (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_hold_fixed

% handles = set_patient_id_popup(handles);
% popupmenu_patient_id_Callback(handles.popupmenu_patient_id, eventdata, handles);

guidata(hObject, handles); % Update handles structure


% --- Executes when selected object is changed in uipanel_pre_post_chemo.
function uipanel_pre_post_chemo_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel_pre_post_chemo 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

handles = set_patient_id_popup(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton_play_movie.
function pushbutton_play_movie_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_play_movie (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

idx = get_img_idx(handles);

colormap gray;
max_frame_rate = 5;
inter_frame_time = 1/max_frame_rate;

text_x = mean(handles.patientdata.crop_x);
text_y = mean(handles.patientdata.crop_y);

numframes = size(handles.PDMI.ImageStackUnregistered, 3);

for kk = 1:numframes
  this_t = handles.PDMI.Time(kk);
  
  saxes(handles.axes_before);
  cla;
  imagesc(handles.PDMI.ImageStackUnregistered(:,:,kk));
  text(text_x, text_y, sprintf('Unregistered t=%0.0f', this_t), 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold', 'horizontalalignment', 'center');
  axis equal tight off

  saxes(handles.axes_after);
  cla;
  imagesc(handles.PDMI.ImageStack(:,:,kk));
  text(text_x, text_y, sprintf('Registered t=%0.0f', this_t), 'FontSize', 16, 'Color', 'r', 'FontWeight', 'bold', 'horizontalalignment', 'center');
  axis equal tight off
  zoom_to_lesion(handles);
  
  pause(inter_frame_time);
end

% Return to imshowpair image
handles = plot_new_image_pair(handles, idx, true);
zoom_to_lesion(handles);
handles.patientdata.h_rect1 = plot_rectangle(handles.axes_before, handles.patientdata.crop_x, handles.patientdata.crop_y);

guidata(hObject, handles); % Update handles structure
