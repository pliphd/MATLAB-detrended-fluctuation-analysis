function varargout = DFATool(varargin)
% DFATOOL MATLAB code for DFATool.fig
%      DFATOOL, by itself, creates a new DFATOOL or raises the existing
%      singleton*.
%
%      H = DFATOOL returns the handle to a new DFATOOL or the handle to
%      the existing singleton*.
%
%      DFATOOL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFATOOL.M with the given input arguments.
%
%      DFATOOL('Property','Value',...) creates a new DFATOOL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFATool_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFATool_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFATool

% Last Modified by GUIDE v2.5 10-Mar-2016 09:50:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFATool_OpeningFcn, ...
                   'gui_OutputFcn',  @DFATool_OutputFcn, ...
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


% --- Executes just before DFATool is made visible.
function DFATool_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFATool (see VARARGIN)

% Choose default command line output for DFATool
handles.output = hObject;

% Adapte position and size
ScreenUnit = get(0, 'Units'); set(0, 'Unit', 'inches');
ScreenSize = get(0, 'ScreenSize');
WindowSize = get(hObject, 'Position');
if ScreenSize(3) < 15
    scale  = 4/5;
else
    scale  = 1/2;
end
WindowWid  = ScreenSize(3)*scale;
WindowHei  = WindowWid/WindowSize(3)*WindowSize(4);
Left   = (ScreenSize(3) - WindowWid) ./ 2;
Bottom = (ScreenSize(4) - WindowHei) ./ 2;
set(hObject, 'Position', [Left Bottom WindowWid WindowHei]);
set(0, 'Units', ScreenUnit);

% User-defined variables
handles.List   = {''}; % file names list
handles.Segs   = {''}; % segment file list
handles.Gaps   = {''}; % gaps file list

handles.SegMk  = 0;    % segment mark: o for undefined
handles.GapMk  = 0;    % gap mark: 0 for undefined
handles.LConf  = 0;    % list file set config mark
handles.FCheck = 0;    % recordings saved in the same folder as *list.txt or not
handles.RunMk  = 0;    % already run DFA or not

handles.ListPt = '';   % *list.txt path
handles.DataPt = '';   % data recordings path
handles.SegPt  = '';   % segment files path
handles.GapPt  = '';   % gap files path
handles.ListNm = '';   % *list.txt file name
handles.ResPt  = '';   % path for saving run results

handles.Epoch  = 1;    % epoch length
handles.Order  = 2;    % default DFA order
handles.SvFig  = 1;    % default not save figures

handles.DFARun = '';   % save path for all analyzing results (high level)
handles.DFAFig = '';   % save path for figures (low level)
handles.DFARes = '';   % save path for DFA results (low level)

handles.InfoFigure = []; % About figure handle

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DFATool wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFATool_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ListPath_Callback(hObject, eventdata, handles)
% hObject    handle to ListPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListPath as text
%        str2double(get(hObject,'String')) returns contents of ListPath as a double


% --- Executes during object creation, after setting all properties.
function ListPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OpenListButton.
function OpenListButton_Callback(hObject, eventdata, handles)
% hObject    handle to OpenListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, FilePath] = uigetfile('*list.txt', 'Select a file contains a list of file names ...');

if ~FileName
    set(handles.ListPath, 'String', 'No file selected!');
else
    handles.ListPt = FilePath;
    handles.ListNm = FileName;
    
    set(handles.ListPath, 'String', fullfile(FilePath, FileName));
    
    set(handles.FileList, 'Value', 1);
    set(handles.SegList, 'Value', 1);
    set(handles.GapList, 'Value', 1);
    
    handles.LConf = 1;
    
    % enable DFA
    if handles.LConf && handles.FCheck
        set(handles.BatchRunButton, 'Enable', 'on');
    end
    
    % Open and display
    fid     = fopen(fullfile(FilePath, FileName), 'r');
    allList = textscan(fid, '%s %s %s');
    fclose(fid);
    
    handles.List = allList{1};
    handles.Segs = allList{2};
    handles.Gaps = allList{3};
    
    set(handles.FileList, 'String', allList{1});
    
    if ~all(cellfun(@isempty, allList{2}))
        set(handles.SegList, 'String', allList{2});
        handles.SegMk = 1;
    else
        set(handles.SegList, 'String', 'No segment file defined!');
    end
    
    if ~all(cellfun(@isempty, allList{3}))
        set(handles.GapList, 'String', allList{3});
        handles.GapMk = 1;
    else
        set(handles.GapList, 'String', 'No gap file defined!');
    end
    
    set(handles.FileNum, 'String', num2str(length(allList{1})));
    
    guidata(hObject, handles);
end


% --- Executes on button press in FolderCheck.
function FolderCheck_Callback(hObject, eventdata, handles)
% hObject    handle to FolderCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FolderCheck
if get(hObject, 'Value')
    set([handles.FolderNameDisp handles.DataPathFind], 'Enable', 'off');
    
    if ~isempty(handles.ListPt)
        handles.FCheck = 1;
        
        [~, FolderName] = fileparts(handles.ListPt);
        set(handles.FolderNameDisp, 'String', FolderName);
        handles.DataPt  = handles.ListPt;
        handles.SegPt   = handles.ListPt;
        handles.GapPt   = handles.ListPt;
    end
    
    if handles.FCheck && handles.LConf
        set(handles.BatchRunButton, 'Enable', 'on');
    end
else
    handles.FCheck = 0;
    set([handles.FolderNameDisp handles.DataPathFind], 'Enable', 'on');
    set(handles.BatchRunButton, 'Enable', 'off');
end
guidata(hObject, handles);


function FolderNameDisp_Callback(hObject, eventdata, handles)
% hObject    handle to FolderNameDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FolderNameDisp as text
%        str2double(get(hObject,'String')) returns contents of FolderNameDisp as a double


% --- Executes during object creation, after setting all properties.
function FolderNameDisp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FolderNameDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DataPathFind.
function DataPathFind_Callback(hObject, eventdata, handles)
% hObject    handle to DataPathFind (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DataFolder = uigetdir(handles.ListPt, 'Select a folder for all signal recordings ...');

if ~DataFolder
    set(handles.FolderNameDisp, 'String', 'No folder selected!');
else
    [~, FolderName] = fileparts(DataFolder);
    set(handles.FolderNameDisp, 'String', FolderName);
    handles.DataPt       = DataFolder;
    handles.SegPt        = fullfile(DataFolder, 'Seg');
    handles.GapPt        = fullfile(DataFolder, 'Gap');
    handles.FCheck  = 1;
    
    % enable DFA
    if handles.LConf && handles.FCheck
        set(handles.BatchRunButton, 'Enable', 'on');
    end
end
guidata(hObject, handles);


function EpochEdit_Callback(hObject, eventdata, handles)
% hObject    handle to EpochEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of EpochEdit as text
%        str2double(get(hObject,'String')) returns contents of EpochEdit as a double
handles.Epoch = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function EpochEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EpochEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in DFAOrder.
function DFAOrder_Callback(hObject, eventdata, handles)
% hObject    handle to DFAOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns DFAOrder contents as cell array
%        contents{get(hObject,'Value')} returns selected item from DFAOrder
contents      = cellstr(get(hObject, 'String'));
handles.Order = str2double(contents{get(hObject, 'Value')});
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function DFAOrder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DFAOrder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in RunType.
function RunType_Callback(hObject, eventdata, handles)
% hObject    handle to RunType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns RunType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from RunType


% --- Executes during object creation, after setting all properties.
function RunType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RunType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveFig.
function SaveFig_Callback(hObject, eventdata, handles)
% hObject    handle to SaveFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of SaveFig
handles.SvFig = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes on button press in BatchRunButton.
function BatchRunButton_Callback(hObject, eventdata, handles)
% hObject    handle to BatchRunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Content = cellstr(get(handles.RunType, 'String'));
Type    = Content{get(handles.RunType, 'Value')};
switch Type
    case 'DFA'
        suffix = 'dfa';
    case 'Magnitude'
        suffix = 'mag';
    case 'RandomShuffling'
        suffix = 'sfl';
end

if get(handles.FolderCheck, 'Value')
    handles.DFARun = handles.DataPt;
    handles.DFARes = handles.DataPt;
    
    if get(handles.SaveFig, 'Value')
        handles.DFAFig = handles.DataPt;
    end
else
    % try making dir
    try
        basePt = fileparts(handles.DataPt);
        handles.ResPt = fullfile(basePt, 'Results');
        if ~(exist(handles.ResPt, 'dir') == 7)
            mkdir(handles.ResPt);
        end
        guidata(hObject, handles);
        
        Date   = datevec(date);
        DFARun = [num2str(Date(1)) sprintf('%02d', Date(2)) sprintf('%02d', Date(3)) '_' Type '_Run_' handles.ListNm(1:end-4)];
        if ~(exist(fullfile(handles.ResPt, DFARun), 'dir') == 7)
            mkdir(fullfile(handles.ResPt, DFARun));
        end
        handles.DFARun = fullfile(handles.ResPt, DFARun);
        
        if ~(exist(fullfile(handles.DFARun, 'Numerical_Results'), 'dir') == 7)
            mkdir(fullfile(handles.DFARun, 'Numerical_Results'));
        end
        handles.DFARes = fullfile(handles.DFARun, 'Numerical_Results');
        
        if get(handles.SaveFig, 'Value')
            if ~(exist(fullfile(handles.DFARun, 'Figure_Results'), 'dir') == 7)
                mkdir(fullfile(handles.DFARun, 'Figure_Results'));
            end
            handles.DFAFig = fullfile(handles.DFARun, 'Figure_Results');
        end
    catch % permission denied!
        handles.DFARun = handles.DataPt;
        handles.DFARes = handles.DataPt;
        
        if get(handles.SaveFig, 'Value')
            handles.DFAFig = handles.DataPt;
        end
    end
end

runTime    = datestr(now);
runTimeVec = datevec(runTime);
LogFid     = fopen(fullfile(handles.DFARun, [Type '_Run_Logs_' sprintf('%02d', runTimeVec(1:3)) '_' sprintf('%02d', runTimeVec(4:6)) '.txt']), 'w');
DFAlistFid = fopen(fullfile(handles.DFARun, [handles.ListNm(1:end-4) suffix num2str(handles.Order) '.list']), 'w');

fprintf(LogFid, '%s\n', runTime);
LogCell = {datestr(now)};
set(handles.Log, 'String', LogCell);
drawnow;

fprintf(LogFid, '\n%s\n', ['Read data recordings from: ' handles.DataPt]);
LogCell = [{['Read data recordings from: ' handles.DataPt]}; {''}; LogCell];
set(handles.Log, 'String', LogCell);
drawnow;

if handles.SegMk
    fprintf(LogFid, '\n%s\n', ['Read segment from: ' handles.SegPt]);
    LogCell = [{['Read segment from: ' handles.SegPt]}; {''}; LogCell];
else
    fprintf(LogFid, '\n%s\n', 'Without segment');
    LogCell = [{'Without segment'}; {''}; LogCell];
end
set(handles.Log, 'String', LogCell);
drawnow;

if handles.GapMk
    fprintf(LogFid, '\n%s\n', ['Read gap from: ' handles.GapPt]);
    LogCell = [{['Read gap from: ' handles.GapPt]}; {''}; LogCell];
else
    fprintf(LogFid, '\n%s\n', 'Without gap');
    LogCell = [{'Without gap'}; {''}; LogCell];
end
set(handles.Log, 'String', LogCell);
drawnow;

fprintf(LogFid, '\n%s\n', '<<');
LogCell = [{'<<'}; {''}; LogCell];
set(handles.Log, 'String', LogCell);
drawnow;

% batch
NumInFact = 0;
for iF = 1:length(handles.List)
    rtxt = fullfile(handles.DataPt, handles.List{iF});
    
    % track
    set(handles.FileList, 'Value', iF);
    if handles.SegMk
        set(handles.SegList, 'Value', iF);
    end
    if handles.GapMk
        set(handles.GapList, 'Value', iF);
    end
    drawnow;
    
    if ~(exist(rtxt, 'file') == 2)
        fprintf(LogFid, '%s\n', [handles.List{iF} ' does not exist.']);
        LogCell = [{[handles.List{iF} ' does not exist.']}; {''}; LogCell];
        set(handles.Log, 'String', LogCell);
        drawnow;
    else
        trec      = load(rtxt);
        NumInFact = NumInFact + 1;
        
        fprintf(LogFid, '%s\n', ['Entering: ' handles.List{iF}]);
        LogCell = [{['Entering: ' handles.List{iF}]}; {''}; LogCell];
        set(handles.Log, 'String', LogCell);
        drawnow;
        
        REC  = trec(:, end); % in case some data files contain also the time
        
        % include segments and exclude gaps
        gap  = ones(length(REC), 1);
        seg  = zeros(length(REC), 1);
        
        if ~handles.SegMk
            seg(1:end)  = 1; % using all
        else
            segfile = fullfile(handles.SegPt, handles.Segs{iF});
            if ~(exist(segfile, 'file') == 2)
                fprintf(LogFid, '%s\n', 'segment not defined.');
                LogCell = [{'segment not defined.'}; LogCell];
                set(handles.Log, 'String', LogCell);
                seg(1:end)  = 1; % using all
            else
                segments = load(segfile);
                segclean = segments(segments(:, 2) - segments(:, 1) > 3600/handles.Epoch, :);
                for iS = 1:size(segclean, 1)
                    seg(segclean(iS, 1):segclean(iS, 2)) = 1;
                end
            end
        end
        drawnow;
        
        if handles.GapMk
            gapfile = fullfile(handles.GapPt, handles.Gaps{iF});
            if ~(exist(gapfile, 'file') == 2)
                fprintf(LogFid, '%s\n', 'gap not defined.');
                LogCell = [{'gap not defined.'}; LogCell];
                set(handles.Log, 'String', LogCell);
            else
                gaps     = load(gapfile);
                gapclean = gaps;
                gapclean(end) = min([gapclean(end) length(REC)]);
                for iG = 1:size(gapclean, 1)
                    gap(gapclean(iG, 1):gapclean(iG, 2)) = 0;
                end
            end
        end
        drawnow;
        
        incl = seg & gap;
        
        incT = diff([0; incl; 0]);
        stId = find(incT == 1);
        edId = find(incT == -1) - 1;
        
        segment = [stId(:) edId(:)];
        
        % adapt series
        if strcmp(Type, 'Magnitude')
            rec = abs(diff(REC));
            segment(:, 2) = segment(:, 2) - 1;
            if segment(1, 2) == 0
                segment(1, 2) = 1;
            end
            if segment(end, 2) < segment(end, 1)
                segment(end, :) = [];
            end
        elseif strcmp(Type, 'RandomShuffling')
            rec = REC;
            recNoGap  = REC(incl);
            randind   = randperm(length(recNoGap));
            rec(incl) = recNoGap(randind);
        else
            rec = REC;
        end
        
        % DFA
        FileNmTemp   = handles.List{iF};
        if handles.SegMk
            SegNmTemp  = handles.Segs{iF};
            FileNmTemp = [FileNmTemp(1:end-4) '_' SegNmTemp(1:end-4)];
        else
            FileNmTemp(end-3:end) = [];
        end
        PrintDFAFile = fullfile(handles.DFARes, [FileNmTemp '.' suffix num2str(handles.Order)]);
        
        % following DFA function needs to be changed in the future for
        % better suiting to this GUI
        [TimeScale, F] = DFA(rec, handles.Order, segment, PrintDFAFile);
        
        TimeAx = (1:length(REC))' .* handles.Epoch ./ 3600;
        
        recForPlot = REC;
        recForPlot(~ incl) = NaN;
        plot(TimeAx, recForPlot, 'k-', 'Parent', handles.Signalaxes);
        set(handles.Signalaxes, 'NextPlot', 'add');
        plot(TimeAx, incl*max(recForPlot), 'Color', [.1 .9 .08], 'Parent', handles.Signalaxes);
        set(handles.Signalaxes, 'NextPlot', 'replace');
        
        if exist('segments', 'var') == 1
            set(handles.Signalaxes, 'XLim', [segments(1) segments(end)] .* handles.Epoch ./ 3600);
        else
            set(handles.Signalaxes, 'XLim', [0 TimeAx(end)]);
        end
        
        switch Type
            case 'RandomShuffling'
                set(handles.Signalaxes, 'NextPlot', 'add');
                shuffled = rec;
                shuffled(~ incl) = NaN;
                plot(TimeAx, shuffled, 'r--', 'Parent', handles.Signalaxes);
                set(handles.Signalaxes, 'NextPlot', 'replace');
        end
        xlabel(handles.Signalaxes, 'Time (h)');
        ylabel(handles.Signalaxes, 'Signal recording');
        loglog(TimeScale .* handles.Epoch ./ 60, F, 'ro', 'Parent', handles.DFAaxes);
        xlabel(handles.DFAaxes, 'Time scale (min)');
        ylabel(handles.DFAaxes, 'Fluctuation amplitude');
        
        if handles.SvFig
            print(fullfile(handles.DFAFig, FileNmTemp), '-djpeg', '-r0');
        end
        
        fprintf(DFAlistFid, '%s\n', [FileNmTemp '.' suffix num2str(handles.Order)]);
    end
    
    fprintf(LogFid, '\n%s\n', '<<');
    LogCell = [{'<<'}; {''}; LogCell];
    set(handles.Log, 'String', LogCell);
    drawnow;
end

fprintf(LogFid, '%s\n', ['Totally ' num2str(NumInFact) ' recordings analyzed.']);
LogCell = [{['Totally ' num2str(NumInFact) ' recordings analyzed.']}; {''}; LogCell];
set(handles.Log, 'String', LogCell);

fprintf(LogFid, '\n%s\n', ['Run logs saved in: ' fullfile(handles.DFARun, [suffix '_Run_Logs_' sprintf('%02d', runTimeVec(1:3)) '_' sprintf('%02d', runTimeVec(4:6)) '.txt'])]);
LogCell = [{['Run logs saved in: ' fullfile(handles.DFARun, [suffix '_Run_Logs_' sprintf('%02d', runTimeVec(1:3)) '_' sprintf('%02d', runTimeVec(4:6)) '.txt'])]}; {''}; LogCell];
set(handles.Log, 'String', LogCell);
drawnow;

fclose(LogFid);
fclose(DFAlistFid);

handles.RunMk = 1;

% Lock Run Button
set(handles.BatchRunButton, 'Enable', 'off');
handles.LConf  = 0;
handles.FCheck = 0;

guidata(hObject, handles);

% --- Executes on selection change in FileList.
function FileList_Callback(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns FileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FileList


% --- Executes during object creation, after setting all properties.
function FileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in GapList.
function GapList_Callback(hObject, eventdata, handles)
% hObject    handle to GapList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns GapList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from GapList


% --- Executes during object creation, after setting all properties.
function GapList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GapList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in SegList.
function SegList_Callback(hObject, eventdata, handles)
% hObject    handle to SegList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns SegList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from SegList


% --- Executes during object creation, after setting all properties.
function SegList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SegList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FileNum_Callback(hObject, eventdata, handles)
% hObject    handle to FileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FileNum as text
%        str2double(get(hObject,'String')) returns contents of FileNum as a double


% --- Executes during object creation, after setting all properties.
function FileNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FileNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Log_Callback(hObject, eventdata, handles)
% hObject    handle to Log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Log as text
%        str2double(get(hObject,'String')) returns contents of Log as a double


% --- Executes during object creation, after setting all properties.
function Log_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function AboutMenu_Callback(hObject, eventdata, handles)
% hObject    handle to AboutMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Info = { ...
    'An interactive tool for detrended fluctuation analysis (DFA).', ...
    '', ...
    ['To use this tool, you need a file named as ''*list.txt'' which specifies a list of file names and those corresponding files are to do DFA.' ...
    ' The list may have up to three colunms. The first colunm specifies the file names; the second one sepcifies the segment file names; the last column is for gap file names.' ...
    ' The last two columns are optional.'], ...
    '', ...
    ['To start DFA analysis, you first click ''Open'' button to select such a list file. Then click ''Find'' button to define the folder that all recordings are saved in.' ...
    ' The final step is to define some configurations as per the measurement protocol. These configuratioins include the epoch length, DFA order, and what type of DFA you will do.'], ...
    '', ...
    ['After all above steps, you click ''batch run'' button and the program runs until all data files specified by the list file are done.' ...
    ' Results will be saved in a new folder created in the data file folder. The name of the new folder always begins with the date doing analysis followed by the type of DFA.'], ...
    '', ...
    '$Author:', ...
    '         Peng Li, Ph.D.', ...
    '         Medical Biodynamics Program', ...
    '         Brigham and Women''s Hospitcal and Harvard Medical School', ...
    '         pli9@bwh.harvard.edu', ...
    '$Date:', ...
    '         Mar 8, 2016', ...
    '$Modif. lists:', ...
    '         Mar 16, 2016', ...
    '             Change result saving path from ''../Data/DFARun/'' to ''../DFARun/''', ...
    '         Plot used episode in Singal axes', ...
    '         Mar 25, 2016', ...
    '             Adpate x axis range', ...
    '         May 6, 2016', ...
    '             Window size adaptable', ...
    '         Nov 15, 2016', ...
    '             Output file names accept segment names as a field if segment specified.', ...
    '         Mar 07, 2017', ...
    '             filter out segments that < 1h and clean gaps (using recording length if the last number is larger than length)', ...
    '         Mar 20, 2017', ...
    '             adapt segment for magnitude analysis'};
try
    close(handles.InfoFigure)
end
handles.InfoFigure = figure('Name', 'About', 'Units', 'inches', 'Position', [4 4 4 2.5], 'MenuBar', 'none', 'ToolBar', 'none', 'Resize', 'off', 'NumberTitle', 'off');
ScreenUnit = get(0, 'Units'); set(0, 'Unit', 'inches');
ScreenSize = get(0, 'ScreenSize');
WindowSize = get(handles.InfoFigure, 'Position');
WindowSize(3) = ScreenSize(3) / 4;
WindowSize(4) = ScreenSize(4) / 4;
Left   = (ScreenSize(3) - WindowSize(3)) ./ 2;
Bottom = (ScreenSize(4) - WindowSize(4)) ./ 2;
WindowSize(1:2) = [Left Bottom];
set(handles.InfoFigure, 'Position', WindowSize);
set(0, 'Units', ScreenUnit);

InfoBox = uicontrol('Parent', handles.InfoFigure, 'Style', 'Edit', 'Units', 'norm', 'Position', [.02 .02 .96 .96], 'Max', 2, 'String', Info, 'HorizontalAlignment', 'left', 'FontName', 'Helvetica');

guidata(hObject, handles);
