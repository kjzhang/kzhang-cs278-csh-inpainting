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
    
%     image = CSH_level(5, image_F, image_O, mask, CSH_w, CSH_i, CSH_k);
    
    % RGB Mask
%     M3 = (repmat(mask, [1 1 3]) == 1);
%     image_F(M3) = 255;

%     image = patch_inpaint(image_F, mask);
    
    % Display final image
%     imshow(image, [], 'parent', handles.image_display);
    guidata(hObject, handles);
else
    disp('User did not select a region');
end


function A_output = CSH_level(level, A, B, mask, CSH_w, CSH_i, CSH_k)
[hB wB dB] = size(B);

if level > 0,   
    % resize A, B, and mask to 50%
    next_A = impyramid(A, 'reduce');
    next_B = impyramid(B, 'reduce');
    [next_hB next_wB next_dB] = size(next_B);
    next_mask = imresize(mask, [next_hB next_wB]);
    
    disp('Resizing images');
%     disp(size(A));
%     disp(size(next_A));
%     disp(size(next_B));
%     disp(size(next_mask));
    
    disp('Getting lower level');
    % CSH_fill the next lowest level
    A_temp = CSH_level(level - 1, next_A, next_B, next_mask, CSH_w, CSH_i, CSH_k);

    % rescale and fill in current level
    A_scale = impyramid(A_temp, 'expand');
    
    disp('processing lower level');
%     disp(size(A_temp));
%     disp(size(A_scale));


    M3 = repmat(mask, [1 1 3]) == 1;
    A(M3) = A_scale(M3);

%     for i = 1:hB,
%         for j = 1:wB,
%             if mask(i, j) == 1,
%                 A(i, j, :) = A_scale(i, j, :);
%             end
%         end
%     end
end

A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k);


function A_output = CSH_fill(A, B, mask, CSH_w, CSH_i, CSH_k)

% width = CSH_w;
% iterations = CSH_i;
% k = CSH_k;

% disp('Beginning CSH Fill');
% disp(size(A));
% disp(size(B));
% disp(size(mask));

[hB wB dB] = size(B);
d = CSH_w - 1;

xmin = 1048576;
xmax = -1;
ymin = 1048576;
ymax = -1;

for i = 1:hB,
    for j = 1:wB,
        if mask(i, j),
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

% disp('xmin:');
% disp(xmin);
% disp('xmax:');
% disp(xmax);
% disp('ymin:');
% disp(ymin);
% disp('ymax:');
% disp(ymax);
% iterative fill with CSH

for nub = 1:25,
    % CSH Patch Match
    
    imshow(A)
    pause(0.001)
    
%     disp(class(A));
%     disp(class(B));
%     disp(class(mask));
%     disp(size(A));
%     disp(size(B));
%     disp(size(mask));
    
    A_next = A;
    
    CSH_ann = CSH_nn(A, B, CSH_w, CSH_i, CSH_k, 0, mask);    
    current_mask = mask;
    s = sum(sum(current_mask));
    while s > 64,
        current_border = getborder(current_mask, 'inside');
        next_mask = logical(current_mask - current_border);
        for row = ymin:ymax,
            for col = xmin:xmax,
                if current_border(row, col) == 1,           
                    n = 0;          
                    s1 = double(0);
                    s2 = double(0);
                    s3 = double(0);

                    for i = (row - d):row,
                        for j = (col - d):col,
                            y = CSH_ann(i, j, 2);
                            x = CSH_ann(i, j, 1);

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
        current_mask = next_mask;
        s = sum(sum(current_mask));
    end

    CSH_ann = CSH_nn(A_next, B, CSH_w, CSH_i, CSH_k, 0, mask);
    
    for row = ymin:ymax,
        for col = xmin:xmax,
            if current_mask(row, col) == 1,           
                n = 0;          
                s1 = double(0);
                s2 = double(0);
                s3 = double(0);

                for i = (row - d):row,
                    for j = (col - d):col,
                        y = CSH_ann(i, j, 2);
                        x = CSH_ann(i, j, 1);

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