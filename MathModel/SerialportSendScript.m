% % this file is created at 20220528
% % brief:    temporary script to send CMD through serialport and process  
% %           recieved data
% % writer:   weyman  


%% 1_prepare code

clc ;                   % clear command line
clear ;                 % clear stack
close all;              % close all hardware objects


%% 2_initialize the necessary data struct

% start_CMD = [0x4F,0x50,0xFF,0xC0,0x45,0x44];
start_CMD = [0x4F,0x50,0xFC,0xC0,0x45,0x44];
global data_raw;
global uart_flag;
data_raw = zeros(1,62);
uart_flag = 0;

%% 3_initialize common components

pause('on');                                            % enable a delay func
serialhandle = serialport("COM4",115200);              % create serialport object
configureCallback(serialhandle, "byte", 62, @weyman_readserial);   


%% 4_communicate with WSN coordinator

write(serialhandle,start_CMD,"uint8");
flush(serialhandle);                                    % clear serialport stack

while 1                                                 % self-adapt time delay to wait WSN collect RSSI data
    if uart_flag == 1
        break; 
    else
        pause(1);
    end
end

weyman_data = data_raw';                                 
save('data_screenshot\weymantest.txt','weyman_data','-ascii');


%% 5_load and prepare necessary data matrix
cd 'data_screenshot'
textsaved = readmatrix('weymantest.txt','OutputType','uint8');
cd ..
RSSI_matrix_raw = textsaved(11:60,4);
RSSI_matrix_sign = 1 + typecast(RSSI_matrix_raw,'int8');                   % switch RSSI data from complement to signed data


%% 6_run filter algorithm 
% % Kalman Filter
% cd ..
% cd 'filter'
% cd 'Kalman_fliter'
% [resault,error] = kalman_fliter_func(RSSI_matrix_sign, length(RSSI_matrix_sign), 0.01, 0.01);
% cd ../..
% cd 'datepending'


% Average Filter
resault = sum(RSSI_matrix_sign)/length(RSSI_matrix_sign);
save('rssi_raw_newtest.txt','resault','-ascii','-append');      % 20221008 test in further automation of script flow

% % Gaussian Filter, can not use in 20220527
% cd ../..
% cd 'filter'
% cd 'Gaussian_fliter'
% [resault,remained] = GaussianFunc(RSSI_matrix_sign', 2, 3);
% cd ../..
% cd '20220526'
% cd 'outdoor'








%% inter function here
function weyman_readserial(serialhandle,~)

global data_raw uart_flag;

data_raw = read(serialhandle, 62, "uint8");                % read a group of RSSI data 
configureCallback(serialhandle,"off");                  % finish one read serialport, close callback
flush(serialhandle);                                    % clear serialport stack
uart_flag = 1;

return;

end









