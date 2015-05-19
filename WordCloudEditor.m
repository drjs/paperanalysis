function varargout = WordCloudEditor(varargin)
% WORDCLOUDEDITOR MATLAB code for WordCloudEditor.fig
%      WORDCLOUDEDITOR, by itself, creates a new WORDCLOUDEDITOR or raises the existing
%      singleton*.
%
%      H = WORDCLOUDEDITOR returns the handle to a new WORDCLOUDEDITOR or the handle to
%      the existing singleton*.
%
%      WORDCLOUDEDITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORDCLOUDEDITOR.M with the given input arguments.
%
%      WORDCLOUDEDITOR('Property','Value',...) creates a new WORDCLOUDEDITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WordCloudEditor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WordCloudEditor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WordCloudEditor

% Last Modified by GUIDE v2.5 19-May-2015 19:00:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WordCloudEditor_OpeningFcn, ...
                   'gui_OutputFcn',  @WordCloudEditor_OutputFcn, ...
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


% --- Executes just before WordCloudEditor is made visible.
function WordCloudEditor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WordCloudEditor (see VARARGIN)

% Choose default command line output for WordCloudEditor
handles.output = hObject;

% check if there is a statistics toolbox license.
if license('test', 'Statistics_Toolbox') ~= 0
    % If not disable cluster options and change panel tooltip to explanation.
    set(handles.cluster_options_panel.Children, 'Enable', 'off');
    set(handles.cluster_options_panel.Children, 'TooltipString', ...
        'Cluster options only available with statistics toolbox');
end
% check the parser was provided
if(nargin > 3)
    for index = 1:2:(nargin-3),
        switch lower(varargin{index})
            case 'parser'
                fac = WordCloud.WordCloudFactory();
                setappdata(handles.wordcloud_editor_figure, 'factory', fac);
                setappdata(handles.wordcloud_editor_figure, 'parser', varargin{index+1});
                initialiseUIObjectsWithFactoryDefaults(handles, fac);
                fac = fac.buildCloud(varargin{index+1});
                setappdata(handles.wordcloud_editor_figure, 'factory', fac);
                break;
            otherwise
                error(['WordCloudEditor not passed an object of type "ParseFiles". ' ...
                    'Use the syntax WordCloudEditor(''parser'', ParseFilesObj);']);
        end
    end
else
    error(['WordCloudEditor not passed an object of type "ParseFiles". ' ...
        'Use the syntax WordCloudEditor(''parser'', ParseFilesObj);']);
end

% Update handles structure
guidata(hObject, handles);

function initialiseUIObjectsWithFactoryDefaults(handles, fac)
    handles.num_words_edit.String = fac.numWords;
    handles.fonts_list.String = fac.fonts;
    handles.text_size_slider.Value = fac.textScaleFactor;
    
    handles.select_background_colour_btn.BackgroundColor = fac.backgroundColour;
    handles.colourmap_menu.String                        = fac.possibleColourMapNames;
    handles.colourmap_menu.Value                         = fac.getColourMapIdx();
    handles.colour_mode_menu.String                      = fac.colouringModes;
    handles.colour_mode_menu.Value                       = fac.getColourModeIdx();
    handles.select_text_colour_btn.BackgroundColor       = fac.textColour;
    setSelectTextButtonState(handles, fac.colourMode, fac.textColour);    
    handles.has_logo_chbx.Value                          = fac.hasLogo;    
    
    handles.num_clusters_slider.Value       = fac.numClusters;
    handles.cluster_separation_slider.Value = fac.clusterDistanceFactor;
    handles.cluster_width_slider.Value      = fac.clusterWidthRatio;
    

function setSelectTextButtonState(handles, colourMode, bgColour)
    if strcmp(colourMode, 'Uniform word colouring')
        % if uniform word colouring, then enable text colour label and button.
        handles.select_text_colour_label.Enable = 'on';
        handles.select_text_colour_btn.Enable = 'on';
        handles.select_text_colour_btn.BackgroundColor = bgColour;
    else
        % otherwise disable text colour label and button.
        handles.select_text_colour_label.Enable = 'off';
        handles.select_text_colour_btn.Enable = 'off';
        handles.select_text_colour_btn.BackgroundColor = ...
            handles.wordcloud_editor_figure.Color;
    end

    
% --- Outputs from this function are returned to the command line.
function varargout = WordCloudEditor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in colourmap_menu.
function colourmap_menu_Callback(hObject, eventdata, handles)
% hObject    handle to colourmap_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colourmap_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colourmap_menu
fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setColourMap(get(hObject,'Value'));
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function colourmap_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colourmap_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in colour_mode_menu.
function colour_mode_menu_Callback(hObject, eventdata, handles)
% hObject    handle to colour_mode_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns colour_mode_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from colour_mode_menu
fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setColourMode(get(hObject,'Value'));
setSelectTextButtonState(handles, fac.colourMode, fac.textColour);
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function colour_mode_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to colour_mode_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in select_text_colour_btn.
function select_text_colour_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_text_colour_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.select_text_colour_btn.BackgroundColor = uisetcolor;
fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setTextColour(handles.select_text_colour_btn.BackgroundColor);
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes on button press in select_background_colour_btn.
function select_background_colour_btn_Callback(hObject, eventdata, handles)
% hObject    handle to select_background_colour_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.select_background_colour_btn.BackgroundColor = uisetcolor;
fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setBackgroundColour(handles.select_background_colour_btn.BackgroundColor);
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes on selection change in fonts_list.
% function fonts_list_Callback(hObject, eventdata, handles)
% hObject    handle to fonts_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fonts_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fonts_list



% --- Executes during object creation, after setting all properties.
function fonts_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fonts_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove_fonts_btn.
function remove_fonts_btn_Callback(hObject, eventdata, handles)
% hObject    handle to remove_fonts_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedFonts = get(handles.fonts_list,'Value');

% Do not delete all the fonts or the cloud will break
% if the user wants to delete all the fonts, they must be educated.
if  numel(selectedFonts) < numel(handles.fonts_list.String)
    % clear all values, otherwise this can cause a value to be larger than
    % number of strings in the listbox, causing an error.
    handles.fonts_list.Value = [];
    % delete selected files
    handles.fonts_list.String(selectedFonts) = [];
    % update fonts in cloud
    fac = getappdata(handles.wordcloud_editor_figure, 'factory');
    fac = fac.setFonts(handles.fonts_list.String);
    setappdata(handles.wordcloud_editor_figure, 'factory', fac);
else
    warndlg({'Deleting all the fonts means the word cloud cannot render.'; ...
        'Do not delete all the fonts at the same time.'});
end


% --- Executes on button press in add_fonts_btn.
function add_fonts_btn_Callback(hObject, eventdata, handles)
% hObject    handle to add_fonts_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get new font and add to listbox
fontinfo = uisetfont;
if ~isequal(fontinfo, 0)
    handles.fonts_list.String = [handles.fonts_list.String; fontinfo.FontName];
    handles.fonts_list.String = unique(handles.fonts_list.String);
    % get fonts in listbox and give to factory.
    fac = getappdata(handles.wordcloud_editor_figure, 'factory');
    fac = fac.setFonts(handles.fonts_list.String);
    setappdata(handles.wordcloud_editor_figure, 'factory', fac);
end


% --- Executes on slider movement.
function text_size_slider_Callback(hObject, eventdata, handles)
% hObject    handle to text_size_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setTextScale(get(hObject,'Value'));
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function text_size_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text_size_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



% --- Executes on slider movement.
function num_clusters_slider_Callback(hObject, eventdata, handles)
% hObject    handle to num_clusters_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
nclust = ceil(get(hObject,'Value'));

fac = getappdata(handles.wordcloud_editor_figure, 'factory');
parser = getappdata(handles.wordcloud_editor_figure, 'parser');
fac = fac.setNumClusters(nclust, parser);
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function num_clusters_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_clusters_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function cluster_separation_slider_Callback(hObject, eventdata, handles)
% hObject    handle to num_clusters_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setClusterSeparation(get(hObject,'Value'));
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function cluster_separation_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_separation_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in has_logo_chbx.
function has_logo_chbx_Callback(hObject, eventdata, handles)
% hObject    handle to has_logo_chbx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of has_logo_chbx

fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setHasLogo(logical(get(hObject,'Value')));
setappdata(handles.wordcloud_editor_figure, 'factory', fac);



function num_words_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_words_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_words_edit as text
%        str2double(get(hObject,'String')) returns contents of num_words_edit as a double
nwords = str2double(get(hObject,'String'));

fac = getappdata(handles.wordcloud_editor_figure, 'factory');
parser = getappdata(handles.wordcloud_editor_figure, 'parser');
fac = fac.setNumWords(nwords, parser);
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function num_words_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_words_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function cluster_width_slider_Callback(hObject, eventdata, handles)
% hObject    handle to cluster_width_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
fac = getappdata(handles.wordcloud_editor_figure, 'factory');
fac = fac.setClusterWidthRatio(get(hObject,'Value'));
setappdata(handles.wordcloud_editor_figure, 'factory', fac);


% --- Executes during object creation, after setting all properties.
function cluster_width_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cluster_width_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in save_settings_btn.
function save_settings_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_settings_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_image_btn.
function save_image_btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_image_btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
