function varargout = udpGrapherV1(varargin)
% UDPGRAPHERV1 MATLAB code for udpGrapherV1.fig
%      UDPGRAPHERV1, by itself, creates a new UDPGRAPHERV1 or raises the existing
%      singleton*.
%
%      H = UDPGRAPHERV1 returns the handle to a new UDPGRAPHERV1 or the handle to
%      the existing singleton*.
%
%      UDPGRAPHERV1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in UDPGRAPHERV1.M with the given input arguments.
%
%      UDPGRAPHERV1('Property','Value',...) creates a new UDPGRAPHERV1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before udpGrapherV1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to udpGrapherV1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help udpGrapherV1

% Last Modified by GUIDE v2.5 15-Jul-2016 16:28:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @udpGrapherV1_OpeningFcn, ...
                   'gui_OutputFcn',  @udpGrapherV1_OutputFcn, ...
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
end

% --- Executes just before udpGrapherV1 is made visible.
function udpGrapherV1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to udpGrapherV1 (see VARARGIN)
    global xlimit;
    global numDataSetsInPacket;
    global xcounter;
    global countToClearBuffer;
  
    global secondsBetweenFlushes;
  
    xlimit = 5000;
    numDataSetsInPacket = 45; %Change this value if needed = # sets of data in a packet
    xcounter = 0;
    countToClearBuffer = 0;    
    secondsBetweenFlushes = 10;
    % Choose default command line output for udpGrapherV1
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes udpGrapherV1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = udpGrapherV1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
end

% --- Executes on button press in startbutton.
function startbutton_Callback(hObject, eventdata, handles)
% hObject    handle to startbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%This is the start button so we want to do alot here....
global t1;
global xlimit;
global numDataSetsInPacket;
global udpClient;
global uPlotSensor1;
global uPlotSensor2;
global uPlotSensor3;
global uPlotSensor4;
global uPlotSensor5;
global uPlotSensor6;

udpClient = udp('footsensor1.dynamic-dns.net',2390, 'LocalPort', 5000);
flushinput(udpClient);
%Add more plots here to window if necessary

    uPlotSensor1 = animatedline('Color','g', 'MaximumNumPoints', xlimit);
    uPlotSensor2 = animatedline('Color','r', 'MaximumNumPoints', xlimit);
    uPlotSensor3 = animatedline('Color','b', 'MaximumNumPoints', xlimit);
    uPlotSensor4 = animatedline('Color','y', 'MaximumNumPoints', xlimit);
    uPlotSensor5 = animatedline('Color','m', 'MaximumNumPoints', xlimit);
    uPlotSensor6 = animatedline('Color','w', 'MaximumNumPoints', xlimit);
    
%Need to add more to get this to work?
%Where do I put local read an plot???
%Setup Udp object
    bytesToRead = (numDataSetsInPacket -1) * 30 + (32); %Reflects length of message recieved may need to be changed
    udpClient.BytesAvailableFcn = {@localReadAndPlot,uPlotSensor1, uPlotSensor2,uPlotSensor3,uPlotSensor4,uPlotSensor5,uPlotSensor6,bytesToRead};
    udpClient.BytesAvailableFcnMode = 'byte';
    udpClient.BytesAvailableFcnCount = bytesToRead;
    udpClient.InputBufferSize = 1000000;
    
    t1 = clock; %Get the first clock value
    fopen(udpClient); 
    pause(3);
    fprintf(udpClient, 'Connection made.');
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
end

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
end

function localReadAndPlot(udpClient,~,uPlotSensor1,uPlotSensor2,uPlotSensor3,uPlotSensor4,uPlotSensor5,uPlotSensor6, bytesToRead)
    global xcounter;
    global xlimit;
    global numDataSetsInPacket;
    global countToClearBuffer;
    global t1;
    global secondsBetweenFlushes;
    
    data = fread(udpClient,bytesToRead);
    dataStr = char(data(1:end-2)'); %Convert to an array
   
    if (length(dataStr) == bytesToRead -2) 
        if xcounter >= xlimit
            xcounter = 0;
            clearpoints(uPlotSensor1);
            clearpoints(uPlotSensor2);
            clearpoints(uPlotSensor3);
            clearpoints(uPlotSensor4);
            clearpoints(uPlotSensor5);
            clearpoints(uPlotSensor6);
        end
        
        %Convert to an array of numbers
        dataNum = sscanf(dataStr, '%d,', bytesToRead);
        if(length(dataNum) == (numDataSetsInPacket * 6))
            dataNum2 = reshape(dataNum,[6,numDataSetsInPacket]);
            sensor1Data = dataNum2(1,:);
            sensor2Data = dataNum2(2,:);
            sensor3Data = dataNum2(3,:);
            sensor4Data = dataNum2(4,:);
            sensor5Data = dataNum2(5,:);
            sensor6Data = dataNum2(6,:);

            xData = xcounter+1:(xcounter+numDataSetsInPacket);

            addpoints(uPlotSensor1, xData, sensor1Data);
            addpoints(uPlotSensor2, xData, sensor2Data);
            addpoints(uPlotSensor3, xData, sensor3Data);
            addpoints(uPlotSensor4, xData, sensor4Data);
            addpoints(uPlotSensor5, xData, sensor5Data);
            addpoints(uPlotSensor6, xData, sensor6Data);
            xcounter = xcounter + numDataSetsInPacket;
            drawnow;
        end
    end
    
    t2 = clock;
    if (etime(t2,t1) > secondsBetweenFlushes)
        flushinput(udpClient);
        disp('Flushed and Reset Clock');
        t1 = clock;
    end 
    
    countToClearBuffer = countToClearBuffer + 1;
end


% --- Executes on button press in stopbutton.
function stopbutton_Callback(hObject, eventdata, handles)
% hObject    handle to stopbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global udpClient;
    global xcounter;
    xcounter = 0;
    flushinput(udpClient);
    fclose(udpClient);
    delete(udpClient);
    clear udpClient;
    fclose(instrfindall);
    %Clear the plot when the figure closes...
    %Add Different booleans to prevent errors
    %TODO: There are a lot of things
end



