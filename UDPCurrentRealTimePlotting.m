
%Udp data logging 

function UDPCurrentRealTimePlotting
    %This function sets up the graphs
    %And initializes the udp listening
    
    %Initialize variables
    global xlimit;
    global numDataSetsInPacket;
    global xcounter;
    global countToClearBuffer;
    global t1;
    global secondsBetweenFlushes;
  
    xlimit = 5000;
    numDataSetsInPacket = 45; %Change this value if needed = # sets of data in a packet
    xcounter = 0;
    countToClearBuffer = 0;    
    secondsBetweenFlushes = 10;
    
    udpClient = udp('footsensor1.dynamic-dns.net',2390, 'LocalPort', 5000);
    flushinput(udpClient);
    
    %Initialize Plot Window
    uFigure = figure('NumberTitle','off',...
        'Name','Live Data Stream Plot',...
        'Color',[0 0 0],...
        'CloseRequestFcn',{@localCloseFigure,udpClient});
    uAxes = axes('Parent',uFigure,...
        'YGrid','on',...
        'YColor',[0.9725 0.9725 0.9725],...
        'XGrid','on',...
        'XColor',[0.9725 0.9725 0.9725],...
        'Color',[0 0 0]);
    xlabel(uAxes,'Number of Samples');
    xlim([0 xlimit]);
    ylabel(uAxes,'Value');
    ylim([0 10000]);
    hold on; %Hold on to allow addition of multiple plots
    
    %Add more plots here to window if necessary
    uPlotSensor1 = animatedline('Color','g', 'MaximumNumPoints', xlimit);
    uPlotSensor2 = animatedline('Color','r', 'MaximumNumPoints', xlimit);
    uPlotSensor3 = animatedline('Color','b', 'MaximumNumPoints', xlimit);
    uPlotSensor4 = animatedline('Color','y', 'MaximumNumPoints', xlimit);
    uPlotSensor5 = animatedline('Color','m', 'MaximumNumPoints', xlimit);
    uPlotSensor6 = animatedline('Color','w', 'MaximumNumPoints', xlimit);
    
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

function localReadAndPlot(udpClient,~,uPlotNumber1,uPlotNumber2,uPlotNumber3,uPlotNumber4,uPlotNumber5,uPlotNumber6, bytesToRead)
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
            clearpoints(uPlotNumber1);
            clearpoints(uPlotNumber2);
            clearpoints(uPlotNumber3);
            clearpoints(uPlotNumber4);
            clearpoints(uPlotNumber5);
            clearpoints(uPlotNumber6);
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

            addpoints(uPlotNumber1, xData, sensor1Data);
            addpoints(uPlotNumber2, xData, sensor2Data);
            addpoints(uPlotNumber3, xData, sensor3Data);
            addpoints(uPlotNumber4, xData, sensor4Data);
            addpoints(uPlotNumber5, xData, sensor5Data);
            addpoints(uPlotNumber6, xData, sensor6Data);
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

function localCloseFigure(figureHandle,~,udpClient)
    flushinput(udpClient);
    fclose(udpClient);
    delete(udpClient);
    clear udpClient;
    delete(figureHandle)
    clear global counter;
    fclose(instrfindall);
end





