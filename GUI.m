function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUI

% Last Modified by GUIDE v2.5 20-Apr-2012 00:50:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in select_image.
function select_image_Callback(hObject, eventdata, handles)
% hObject    handle to select_image (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, PathName] = uigetfile({'*.png; *.jpg; *.bmp; *.gif; *.tif', ...
    'All Image Files (*.png, *.jpg, *.bmp, *.gif, *.tif)'}, ...
    'Choose an image file');
if isequal(FileName, 0)
    disp('User did not upload an image')
else
    disp(['User selected: ', fullfile(PathName, FileName)]);
    handles.image = imread(fullfile(PathName, FileName));
    handles.image_url = fullfile(PathName, FileName);
    imshow(handles.image, [], 'parent', handles.image_display);
    guidata(hObject, handles);
end

% --- Executes on button press in select_region.
function select_region_Callback(hObject, eventdata, handles)
% hObject    handle to select_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.region = impoly(handles.image_display);
guidata(hObject, handles);

% --- Executes on button press in fill_region.
function fill_region_Callback(hObject, eventdata, handles)
% hObject    handle to fill_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pause on;

if isfield(handles, 'region'),
    mask = createMask(handles.region);
    
    % Original and interpolated images
    image_O = handles.image;
    imageR = roifill(image_O(:,:,1), mask);
    imageG = roifill(image_O(:,:,2), mask);
    imageB = roifill(image_O(:,:,3), mask);
    image_F = cat(3, imageR, imageG, imageB);
    
    disp(size(image_O));
    disp(size(image_F));
    disp(size(mask));
    
    % CSH parameters
    CSH_w = 8;
    CSH_i = 3;
    CSH_k = 1;
    
    image = CSH_inpaint(image_F, image_O, mask, CSH_w, CSH_i, CSH_k);
    % Display final image
    % imshow(image, [], 'parent', handles.image_display);
    guidata(hObject, handles);
else
    disp('User did not select a region');
end