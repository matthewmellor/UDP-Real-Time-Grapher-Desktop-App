%UDP Logger Test
function udptest
    %fclose(instrfindall); %May need to comment this out if first time running script
    u = udp('18.111.54.180',2390, 'LocalPort', 5000); %Ip address of server
    %2390 is the port of the server
    %5000 is the local port
    %Values above need to be changed to reflect the values of the esp8266
    u.InputBufferSize = 1000000;
    bytesToRead = 44 *30 + 32; %Remember it is necessary to set as X because of message size. May need to change
    fopen(u);
    fprintf(u, 'It is I Matlab Script.');
    pause(3);
    for m=1:100000
        %data = fscanf(u,'%d,%d,%d,%d,%d,%d\n\r',31)
        data = fread(u,bytesToRead);
        dataStr = char(data(1:end-2)'); 
        length(dataStr);
        dataNum = sscanf(dataStr, '%d,', bytesToRead);
        dataNum2 = reshape(dataNum,[6,45]);
        length(dataNum)
        %length(dataStr)
    end
    fclose(u);
end