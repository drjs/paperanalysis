function varargout = GetFilesUI(varargin)
%GETFILESUI M-file for GetFilesUI.fig
%      GETFILESUI, by itself, creates a new GETFILESUI or raises the existing
%      singleton*.
%
%      H = GETFILESUI returns the handle to a new GETFILESUI or the handle to
%      the existing singleton*.
%
%      GETFILESUI('Property','Value',...) creates a new GETFILESUI using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to GetFilesUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      GETFILESUI('CALLBACK') and GETFILESUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in GETFILESUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GetFilesUI

% Last Modified by GUIDE v2.5 22-Apr-2015 17:20:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GetFilesUI_OpeningFcn, ...
    'gui_OutputFcn',  @GetFilesUI_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before GetFilesUI is made visible.
function GetFilesUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for GetFilesUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set current folder as last folder viewed by ui
setappdata(handles.mainFig, 'LastFolderViewed', pwd);
% specify what data formats are supported
setappdata(handles.mainFig, 'SupportedFormats', {'*.txt'; '*.pdf'; '*.doc'; '*.docx'});
% enable multiple select on the list box
handles.file_listbox.Max = 2;


% UIWAIT makes GetFilesUI wait for user response (see UIRESUME)
% uiwait(handles.mainFig);


% --- Outputs from this function are returned to the command line.
function varargout = GetFilesUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in file_listbox.
function file_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns file_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from file_listbox


% --- Executes during object creation, after setting all properties.
function file_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function manualpath_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to manualpath_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function manualpath_edit_Callback(hObject, eventdata, handles)
% hObject    handle to add_manualpath_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_manualpath_btn_Callback(hObject, eventdata, handles);

% --- Executes on button press in add_manualpath_btn.
function add_manualpath_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_manualpath_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get text string from edit box
str = handles.manualpath_edit.String;
% is it a folder or a file?
if exist(str, 'dir')
    % convert to absolute path
    folder = System.IO.Path.GetFullPath(str);
    addFolderToFileList(handles, char(folder));
elseif exist(str, 'file')
    filename = System.IO.Path.GetFullPath(str);
    appendToFileList(handles, char(filename) );
end

% --- Executes on button press in add_file_btn.
function add_file_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_file_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% open UI to select a file
startfolder = getappdata(handles.mainFig, 'LastFolderViewed');
formats = getappdata(handles.mainFig, 'SupportedFormats');
[f,p] = uigetfile(formats, 'Select File to add to Word Cloud', startfolder);

if ~isequal(f,0) % if the user actually selected a file instead of cancelling
    % add file to file list
    appendToFileList(handles, fullfile(p,f));
    % tell next thing to open in the selected folder.
    setappdata(handles.mainFig, 'LastFolderViewed', p);
end

% --- Executes on button press in add_folder_btn.
function add_folder_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_folder_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

startfolder = getappdata(handles.mainFig, 'LastFolderViewed');
% open UI to select a folder
folder = uigetdir(startfolder, 'Select Folder to add to Word Cloud');

if ~isequal(folder,0) % if the user actually selected a folder instead of cancelling
    addFolderToFileList(handles, folder);
    % tell next thing to open in the selected folder.
    setappdata(handles.mainFig, 'LastFolderViewed', folder);
end

% --- Executes on button press in add_plaintext_btn.
function add_plaintext_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_plaintext_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% create input dialogue to get plain text info
inputBoxSizes = [1, 53; 10, 50];
dialogueOutput = {'';''};
% loop box checks until some valid input is found.
% valid inputs are :
% - cancel input dlg
% - nothing (in which case cancel)
% - both fields are filled.

while isempty(dialogueOutput{1}) || isempty(dialogueOutput{2})
    dialogueOutput = inputdlg({'Title', 'Text'}, 'Enter Plain Text', inputBoxSizes, dialogueOutput);
    % check for valid inputs
    if isempty(dialogueOutput) % user cancelled
        return;
    elseif isempty(dialogueOutput{1}) && isempty(dialogueOutput{2}) % no data entered.
        return;
    elseif isempty(dialogueOutput{1}) % no title
         uiwait(msgbox('No title entered!', 'No title warning'));
    elseif isempty(dialogueOutput{2}) % no text
         uiwait(msgbox('No text entered!', 'No text warning'));
    end
end

% getting here means that the user entered a title and some text.
% save this as a txt file 
savefolder = getappdata(handles.mainFig, 'LastFolderViewed');
filename = fullfile(savefolder, [dialogueOutput{1}, '.txt'])
fid = fopen(filename, 'w');
% write text to file row by row.
for row = 1:size(dialogueOutput{2}, 1)
    fprintf(fid, dialogueOutput{2}(row,:) );
    fprintf(fid, '\n');
end
fclose(fid);
% add new file to file list
appendToFileList(handles, filename);


% --- Executes on button press in remove_btn.
function remove_btn_Callback(hObject, eventdata, handles)
% hObject    handle to remove_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
flist = getappdata(handles.file_listbox, 'FileList');
selected = handles.file_listbox.Value;
% delete selected files
flist(selected) = [];
% clear all values, otherwise this can cause a value to be larger than
% number of strings in the listbox, causing an error.
handles.file_listbox.Value = []; 
% update file list internally and in the listbox display
setappdata(handles.file_listbox, 'FileList', flist);
setListBoxString(handles, flist);


% --- Executes on button press in generate_cloud_btn.
function generate_cloud_btn_Callback(hObject, eventdata, handles)
% hObject    handle to generate_cloud_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in generate_surface_btn.
function generate_surface_btn_Callback(hObject, eventdata, handles)
% hObject    handle to generate_surface_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function addFolderToFileList(handles, folder)
formats = getappdata(handles.mainFig, 'SupportedFormats');
% get list of all files with the supported file extensions
files = {};
for ext = formats'
    % use DIR to get list of files with supported file extension
    files = [dir( fullfile(folder, ext{1})); files]; %#ok<AGROW>
end
files = {files.name}';

% add these files to the list of files we saved
appendToFileList(handles, fullfile(folder, files) );



function appendToFileList(handles, newfiles)
flist = getappdata(handles.file_listbox, 'FileList');

if isempty(flist)
    if iscell(newfiles)
        flist = newfiles;
    else
        flist = {newfiles};
    end
else
    flist = [flist; newfiles];
end
setappdata(handles.file_listbox, 'FileList', flist);
setListBoxString(handles, flist);


function setListBoxString(handles, fileList)
% update list box with new file list, excluding full path name
[~,names,exts] = cellfun(@fileparts, fileList, 'UniformOutput', false);
handles.file_listbox.String = strcat(names, exts);
% update list box with new file list INCLUDING full path name
% handles.file_listbox.String = fileList;
