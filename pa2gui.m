function varargout = pa2gui(varargin)
% PA2GUI MATLAB code for pa2gui.fig
%      PA2GUI, by itself, creates a new PA2GUI or raises the existing
%      singleton*.
%
%      H = PA2GUI returns the handle to a new PA2GUI or the handle to
%      the existing singleton*.
%
%      PA2GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PA2GUI.M with the given input arguments.
%
%      PA2GUI('Property','Value',...) creates a new PA2GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before pa2gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to pa2gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help pa2gui

% Last Modified by GUIDE v2.5 15-Apr-2012 19:39:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pa2gui_OpeningFcn, ...
                   'gui_OutputFcn',  @pa2gui_OutputFcn, ...
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


% --- Executes just before pa2gui is made visible.
function pa2gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to pa2gui (see VARARGIN)

% Choose default command line output for pa2gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes pa2gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = pa2gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get image A from file upload
[FileName, PathName] = uigetfile({'*.png; *.jpg; *.bmp; *.gif; *.tif', 'All Image Files (*.png, *.jpg, *.bmp, *.gif, *.tif)'}, 'Choose an imamge file');
if isequal(FileName, 0)
    disp('User did not upload an image')
else
    disp(['User selected', fullfile(PathName, FileName)])
    A = imread(fullfile(PathName, FileName));
    handles.image = A;
    handles.imageurl = fullfile(PathName, FileName);
    axes(handles.axes1);
    imshow(handles.image, []);
    guidata(hObject, handles);
end


function A_output = CSH_level(level, A, B, mask, CSH_w, CSH_i, CSH_k)

[hB wB dB] = size(B);

ratio = 0.5;

if level > 0,
    new_hB = ceil(hB * ratio);
    new_wB = ceil(wB * ratio);
    
    next_A = impyramid(A, 'reduce');
    next_B = next_A;
    
%     next_A = imresize(A, [new_hB new_wB]);
%     next_B = next_A;
    
    next_mask = imresize(mask, [ceil(hB / 2) ceil(wB / 2)]);
    
    for i = 1:new_hB,
        for j = 1:new_wB,
            if next_mask(i, j) ~= 0,
                next_mask(i, j) = 1;
            end
        end
    end
    
    A_temp = CSH_level(level - 1, next_A, next_B, next_mask, CSH_w, CSH_i, CSH_k);
    
    A_scale = impyramid(A_temp, 'expand');
    
    for i = 1:hB,
        for j = 1:wB,
            if mask(i, j) == 1,
                A(i, j) = A_scale(i, j);
            end
        end
    end
    
    A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k);
else
    A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k);
end


function A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k)
% CSH_w width
% CSH_i iterations
% CSH_k

[hB wB dB] = size(B);

width = CSH_w;
iterations = CSH_i;
k = CSH_k;

d = width - 1;

xmin = 1048576;
xmax = -1;
ymin = 1048576;
ymax = -1;

for i = 1:hB,
    for j = 1:wB,
        if mask(i, j) == 1,
            if xmin > j,
                xmin = j;
            end
            if xmax < j,
                xmax = j;
            end
            if ymin > i,
                ymin = i;
            end
            if ymax < i,
                ymax = i;
            end
        end
    end
end

A_next = A;


for nub = 1:1,
    CSH_ann = CSH_nn(A, B, width, iterations, k, 0, mask);
    for row = (ymin):(ymax),
        for col = (xmin):(xmax),
            if mask(row, col) == 1,           
                n = 0;
                s1 = double(0);
                s2 = double(0);
                s3 = double(0);
                for i = (row - d):row,
                    for j = (col - d):col,
                        x = CSH_ann(i, j, 1);
                        y = CSH_ann(i, j, 2);
                        B_row = y + (row - i);
                        B_col = x + (col - j);
                        
                        if B_row > 0 && B_row < (hB + 1) && B_col > 0 && B_col < (wB + 1),
                            % original
                            p1 = B(B_row, B_col, 1);
                            p2 = B(B_row, B_col, 2);
                            p3 = B(B_row, B_col, 3);
                            s1 = s1 + double(p1);
                            s2 = s2 + double(p2);
                            s3 = s3 + double(p3);
                            n = n + 1;
                        end
                    end
                end

                n = double(n);
                s1 = s1 / n;
                s2 = s2 / n;
                s3 = s3 / n;

                A_next(row, col, 1) = round(s1);
                A_next(row, col, 2) = round(s2);
                A_next(row, col, 3) = round(s3);
            end
        end
    end
    
    A = A_next;
    disp(nub);
    
end

A_output = A;


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% We will calculate where the region is and calculate the CNN and do other
% things
A = handles.image;
B = handles.image;
    
[hB wB dB] = size(handles.image);

width = 8;
iterations = 5;
k = 1;
levels = 6;

region = handles.region;

mask = createMask(region);

% disp(mask);

A_output = CSH_level(levels, A, B, mask, width, iterations, k);

figure;
imshow(A_output, [])
guidata(hObject, handles);

%mask(round(getPosition(handles.region))) = 1;
%CSH_ann = CSH_nn(A,A,width,iterations,k,0,mask);


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
if (isfield(handles, 'region'))
    delete(handles.region);
end

handles.region = imfreehand();
handles.eps = getPosition(handles.region);
guidata(hObject, handles);
