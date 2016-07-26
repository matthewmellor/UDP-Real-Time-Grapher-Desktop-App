function varargout = udpGrapherV1(varargin)
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

% --- Outputs from this function are returned to the command line.
function varargout = udpGrapherV1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
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
    global startBeenPressed;
    global everStarted;
    global stopBeenPressed;
  
    xlimit = 5000;
    numDataSetsInPacket = 45; %Change this value if needed = # sets of data in a packet
    xcounter = 0;
    countToClearBuffer = 0;    
    secondsBetweenFlushes = 10;
    startBeenPressed = false;
    everStarted = false;
    stopBeenPressed = false;
    
    % Choose default command line output for udpGrapherV1
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

% UIWAIT makes udpGrapherV1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);
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
    global startBeenPressed;
    global everStarted;
    global stopBeenPressed;
    
    if(~startBeenPressed) %I think there needs to be more here
        if(stopBeenPressed)
            %Clear the axes...
            %How to clear the axes
            stopBeenPressed = false;
            %TODO
        end
        startBeenPressed = true;
        everStarted = true;
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
        fprintf(udpClient, 'Connection made.');
        pause(3);
    end
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
    global startBeenPressed;
    global stopBeenPressed;
    if(startBeenPressed)
        startBeenPressed = false;
        stopBeenPressed = true;
        xcounter = 0;
        flushinput(udpClient);
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
        fclose(instrfindall);
    end
end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global udpClient;
    global startBeenPressed;
    global everStarted;
    if(startBeenPressed && everStarted) %This means there is still a udp connection
        flushinput(udpClient);
        fclose(udpClient);
        delete(udpClient);
        clear udpClient;
        fclose(instrfindall); %Is this necessary?? TODO
    end
end






%%----CheckBox Code ------





% --- Executes during object creation, after setting all properties.
function checkbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    set(hObject,'Value',1);
end

% --- Executes during object creation, after setting all properties.
function checkbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    set(hObject,'Value',1);
end


% --- Executes during object creation, after setting all properties.
function checkbox6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    set(hObject,'Value',1);
end

% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
    global uPlotSensor1;
    global startBeenPressed;
    if(startBeenPressed)
        if(get(hObject, 'Value') == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor1,'Visible','off');
        else
            %we received a one
            set(uPlotSensor1, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
    global uPlotSensor2;
    global startBeenPressed;
    if(startBeenPressed)
        if(get(hObject, 'Value') == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor2,'Visible','off');
        else
            %we received a one
            set(uPlotSensor2, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
    global startBeenPressed;
    global uPlotSensor3;
    if(startBeenPressed)
        if(get(hObject, 'Value') == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor3,'Visible','off');
        else
            %we received a one
            set(uPlotSensor3, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
%Check box = 1 if checked == 0 if not checked
%TODO:  Need to see if it is possible to precheck the check boxes
    global uPlotSensor4;
    global startBeenPressed;
    if(startBeenPressed)
        if(get(hObject, 'Value') == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor4,'Visible','off');
        else
            %we received a one
            set(uPlotSensor4, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5
    global uPlotSensor5;
    global startBeenPressed;
    if(startBeenPressed)
        if(get(hObject, 'Value') == 0)
          %Set plot 1 to be invisible
          set(uPlotSensor5,'Visible','off');
        else
            %we received a one
            set(uPlotSensor5, 'Visible', 'on');
        end
    end
end

% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
    global uPlotSensor6;
    global startBeenPressed;
    if(startBeenPressed)
            if(get(hObject, 'Value') == 0)
              %Set plot 1 to be invisible
              set(uPlotSensor6,'Visible','off');
            else
                %we received a one
                set(uPlotSensor6, 'Visible', 'on');
            end
    end
end

