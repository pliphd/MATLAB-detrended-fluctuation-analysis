function varargout = DFAFit(varargin)
% DFAFIT MATLAB code for DFAFit.fig
%      DFAFIT, by itself, creates a new DFAFIT or raises the existing
%      singleton*.
%
%      H = DFAFIT returns the handle to a new DFAFIT or the handle to
%      the existing singleton*.
%
%      DFAFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFAFIT.M with the given input arguments.
%
%      DFAFIT('Property','Value',...) creates a new DFAFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFAFit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFAFit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFAFit

% Last Modified by GUIDE v2.5 26-Aug-2016 16:06:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DFAFit_OpeningFcn, ...
                   'gui_OutputFcn',  @DFAFit_OutputFcn, ...
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


% --- Executes just before DFAFit is made visible.
function DFAFit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFAFit (see VARARGIN)

% Choose default command line output for DFAFit
handles.output = hObject;

% Adapte position
ScreenUnit = get(0, 'Units'); set(0, 'Unit', 'inches');
ScreenSize = get(0, 'ScreenSize');
WindowSize = get(hObject, 'Position');
Left   = (ScreenSize(3) - WindowSize(3)) ./ 2;
Bottom = (ScreenSize(4) - WindowSize(4)) ./ 2;
WindowSize(1:2) = [Left Bottom];
set(hObject, 'Position', WindowSize);
set(0, 'Units', ScreenUnit);

% User-defined variables
handles.FitListPt = '';   % *dfa*.txt or *mag*.txt path
handles.FitListNm = '';   % list file name
handles.DFAResPt  = '';   % DFA/Mag results folder
handles.DFARun    = '';   % highest level folder generated when run DFA

handles.LConf     = 0;    % list file openned config
handles.DConf     = 0;    % data path set config
handles.RConf     = 0;    % naming rule set config

handles.List      = {''}; % file name list
handles.NameRl    = '';   % recordings naming rule

handles.Epoch     = 1;    % epoch length, unit: sec
handles.minscale  = 1;    % range left broader, unit: min
handles.maxscale  = 90;   % range right broader, unit: min
handles.mwn       = 4;    % minmum windows number for fit

handles.FitSV     = 1;    % save figure or not

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DFAFit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFAFit_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function FitListPath_Callback(hObject, eventdata, handles)
% hObject    handle to FitListPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitListPath as text
%        str2double(get(hObject,'String')) returns contents of FitListPath as a double


% --- Executes during object creation, after setting all properties.
function FitListPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitListPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in OpenFitListButton.
function OpenFitListButton_Callback(hObject, eventdata, handles)
% hObject    handle to OpenFitListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, FilePath] = uigetfile({'*dfa*.list'; '*mag*.list'}, 'Select a file contains a list of file names ...');

if ~FileName
    set(handles.FitListPath, 'String', 'No file selected!');
else
    handles.FitListPt = FilePath;
    handles.FitListNm = FileName;
    
    set(handles.FitListPath, 'String', fullfile(FilePath, FileName));
    
    handles.LConf = 1;
    
    % enable DFA
    if handles.LConf && handles.DConf && handles.RConf
        set(handles.FitRunButton, 'Enable', 'on');
    end
    
    % Open and display
    fid     = fopen(fullfile(FilePath, FileName), 'r');
    allList = textscan(fid, '%s');
    fclose(fid);
    
    handles.List = allList{1};
    set(handles.FitList, 'String', allList{1});
    set(handles.ListNum, 'String', num2str(length(allList{1})));
    
    guidata(hObject, handles);
end


function NamePath_Callback(hObject, eventdata, handles)
% hObject    handle to NamePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NamePath as text
%        str2double(get(hObject,'String')) returns contents of NamePath as a double


% --- Executes during object creation, after setting all properties.
function NamePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NamePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in NamePathSelect.
function NamePathSelect_Callback(hObject, eventdata, handles)
% hObject    handle to NamePathSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[FileName, FilePath] = uigetfile('*ParseName.m', 'Select a *.m file defining the naming rule ...');

if ~FileName
    set(handles.NamePath, 'String', 'No file selected!');
else
    set(handles.NamePath, 'String', fullfile(FilePath, FileName));
    
    handles.NameRl = FileName(1:end-2);
    handles.RConf  = 1;
    
    % enable DFA
    if handles.LConf && handles.DConf && handles.RConf
        set(handles.FitRunButton, 'Enable', 'on');
    end
end
guidata(hObject, handles);


function DFAResPath_Callback(hObject, eventdata, handles)
% hObject    handle to DFAResPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DFAResPath as text
%        str2double(get(hObject,'String')) returns contents of DFAResPath as a double


% --- Executes during object creation, after setting all properties.
function DFAResPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DFAResPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DFAResultsSelect.
function DFAResultsSelect_Callback(hObject, eventdata, handles)
% hObject    handle to DFAResultsSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
DataFolder = uigetdir(handles.FitListPt, 'Select a folder for DFA/Mag results ...');

if ~DataFolder
    set(handles.DFAResPath, 'String', 'No folder selected!');
else
    [handles.DFARun, FolderName]  = fileparts(DataFolder);
    set(handles.DFAResPath, 'String', FolderName);
    handles.DFAResPt = DataFolder;
    handles.DConf  = 1;
    
    % enable DFA
    if handles.DConf && handles.LConf && handles.RConf
        set(handles.FitRunButton, 'Enable', 'on');
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


function MinScale_Callback(hObject, eventdata, handles)
% hObject    handle to MinScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MinScale as text
%        str2double(get(hObject,'String')) returns contents of MinScale as a double
handles.minscale = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MinScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function MaxScale_Callback(hObject, eventdata, handles)
% hObject    handle to MaxScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MaxScale as text
%        str2double(get(hObject,'String')) returns contents of MaxScale as a double
handles.maxscale = str2double(get(hObject, 'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function MaxScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FitSvFig.
function FitSvFig_Callback(hObject, eventdata, handles)
% hObject    handle to FitSvFig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of FitSvFig
handles.FitSF = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes on button press in FitRunButton.
function FitRunButton_Callback(hObject, eventdata, handles)
% hObject    handle to FitRunButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% try making dir
try
    if get(handles.FitSvFig, 'Value')
        if ~(exist(fullfile(handles.DFARun, 'Fit_Figure'), 'dir') == 7)
            mkdir(fullfile(handles.DFARun, 'Fit_Figure'));
        end
        handles.FitFig = fullfile(handles.DFARun, 'Fit_Figure');
    end
catch % permission denied!
    if get(handles.FitSvFig, 'Value')
        handles.FitFig = handles.DFAResPt;
    end
end

runTime    = datestr(now);
runTimeVec = datevec(runTime);
LogFid     = fopen(fullfile(handles.DFARun, ['Fit_Run_Logs_scale_' num2str(handles.minscale) '_' num2str(handles.maxscale) '_' sprintf('%02d', runTimeVec(1:3)) '_' sprintf('%02d', runTimeVec(4:6)) '.txt']), 'w');

[~, DFAListNm, suffix] = fileparts(handles.FitListNm);
FitResFile = fullfile(handles.DFARun, [DFAListNm '_' suffix(2:end) '_fit_' num2str(handles.minscale) '_' num2str(handles.maxscale) '.csv']);

fprintf(LogFid, '%s\n', runTime);
LogCell = {datestr(now)};
set(handles.FitLog, 'String', LogCell);
drawnow;

fprintf(LogFid, '\n%s\n', ['Read DFA results from: ' handles.DFAResPt]);
LogCell = [{['Read DFA results from: ' handles.DFAResPt]}; {''}; LogCell];
set(handles.FitLog, 'String', LogCell);
drawnow;

fprintf(LogFid, '\n%s\n', '<<');
LogCell = [{'<<'}; {''}; LogCell];
set(handles.FitLog, 'String', LogCell);
drawnow;

% batch
NumInFact = 0;
TABLE  = [];
for iF = 1:length(handles.List)
    rtxt = fullfile(handles.DFAResPt, handles.List{iF});
    
    % track
    set(handles.FitList, 'Value', iF);
    
    if ~(exist(rtxt, 'file') == 2)
        fprintf(LogFid, '%s\n', [handles.List{iF} ' does not exist.']);
        LogCell = [{[handles.List{iF} ' does not exist.']}; {''}; LogCell];
        set(handles.FitLog, 'String', LogCell);
        drawnow;
    else
        trec      = load(rtxt);
        NumInFact = NumInFact + 1;
        
        fprintf(LogFid, '%s\n', ['Entering: ' handles.List{iF}]);
        LogCell = [{['Entering: ' handles.List{iF}]}; LogCell];
        set(handles.FitLog, 'String', LogCell);
        
        timescale = trec(:, 1);
        F         = trec(:, 2);
        windowNum = trec(:, 3);
        
        % fit
        validind  = find(timescale >= 5 & windowNum >= handles.mwn);
        minscale  = max(timescale(validind(1)),   handles.minscale * 60 / handles.Epoch);
        maxscale  = min(timescale(validind(end)), handles.maxscale * 60 / handles.Epoch);
        
        rangeind  = timescale >= minscale & timescale <= maxscale;
        LogF      = log(F(rangeind));
        LogTimesc = log(timescale(rangeind));
        
        p         = polyfit(LogTimesc, LogF, 1);
        alpha     = p(1);
        InterSect = p(2);
        
        FitLogF   = polyval(p, LogTimesc);
        R2        = 1 - ((FitLogF - LogF)'*(FitLogF - LogF)) / ((LogF - mean(LogF))'*(LogF - mean(LogF)));
        
        loglog(timescale .* handles.Epoch ./ 3600, F, 'ro', timescale(rangeind) .* handles.Epoch ./ 3600, exp(FitLogF), 'b', 'Parent', handles.Fitaxes);
        xlabel('Time scale (hours)');
        ylabel('Fluctuation amplitude');
        drawnow;
        
        FileNmTmp = handles.List{iF};
        if handles.FitSV
            print(fullfile(handles.FitFig, [FileNmTmp(1:end-5) '_' num2str(handles.minscale) '_' num2str(handles.maxscale)]), '-djpeg', '-r0');
        end
        
        NameStruct = feval(handles.NameRl, FileNmTmp(1:end-5));
        InfoTable  = struct2table(NameStruct);
        
        FitResTab  = table(minscale * handles.Epoch / 60, maxscale * handles.Epoch / 60, alpha, R2, InterSect, 'VariableName', {'MinScale', 'MaxScale', 'Alpha', 'Goodness', 'Intersection'});
        
        TABLE      = [TABLE; [InfoTable FitResTab]];
    end
    
    fprintf(LogFid, '\n%s\n', '<<');
    LogCell = [{'<<'}; {''}; LogCell];
    set(handles.FitLog, 'String', LogCell);
    drawnow;
end

fprintf(LogFid, '%s\n', ['Totally ' num2str(NumInFact) ' files analyzed.']);
LogCell = [{['Totally ' num2str(NumInFact) ' files analyzed.']}; {''}; LogCell];
set(handles.FitLog, 'String', LogCell);
drawnow;

fprintf(LogFid, '\n%s\n', ['Run logs saved in: ' fullfile(handles.DFARun, ['Fit_Run_Logs_scale_' num2str(handles.minscale) '_' num2str(handles.maxscale) '_' sprintf('%02d', runTimeVec(1:3)) '_' sprintf('%02d', runTimeVec(4:6)) '.txt'])]);
LogCell = [{['Run logs saved in: ' fullfile(handles.DFARun, ['Fit_Run_Logs_scale_' num2str(handles.minscale) '_' num2str(handles.maxscale) '_' sprintf('%02d', runTimeVec(1:3)) '_' sprintf('%02d', runTimeVec(4:6)) '.txt'])]}; {''}; LogCell];
set(handles.FitLog, 'String', LogCell);
drawnow;

fclose(LogFid);
writetable(TABLE, FitResFile);


function FitList_Callback(hObject, eventdata, handles)
% hObject    handle to FitList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitList as text
%        str2double(get(hObject,'String')) returns contents of FitList as a double


% --- Executes during object creation, after setting all properties.
function FitList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ListNum_Callback(hObject, eventdata, handles)
% hObject    handle to ListNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ListNum as text
%        str2double(get(hObject,'String')) returns contents of ListNum as a double


% --- Executes during object creation, after setting all properties.
function ListNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ListNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FitLog_Callback(hObject, eventdata, handles)
% hObject    handle to FitLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of FitLog as text
%        str2double(get(hObject,'String')) returns contents of FitLog as a double


% --- Executes during object creation, after setting all properties.
function FitLog_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FitLog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MWN_Callback(hObject, eventdata, handles)
% hObject    handle to MWN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MWN as text
%        str2double(get(hObject,'String')) returns contents of MWN as a double
handles.mwn = str2double(get(hObject, 'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function MWN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MWN (see GCBO)
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
    'This is for fitting the results generated by DFATool. SOP tba.', ...
    '', ...
    '$Author:', ...
    '         Peng Li, Ph.D.', ...
    '         Medical Biodynamics Program', ...
    '         Brigham and Women''s Hospitcal and Harvard Medical School', ...
    '         pli9@bwh.harvard.edu', ...
    '$Date:', ...
    '         Feb 12, 2016', ...
    '$Modif. lists:', ...
    '         Aug 24, 2016', ...
    '             Add About Menu and change unit, window resizable.', ...
    '         Sep 1, 2016', ...
    '             GUI modif.'};
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
