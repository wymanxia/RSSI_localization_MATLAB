% % File name:        weyman_all_flow
% % Create date:      2022.3.17
% % Writer:           Weyman 
% % Brief:            Localization all flow in real time sequence
% % Latest change:    2022.11.9
% % Change note:      Add datatype switch code to Anchors_rssi_data(from 
% %                   int8 to double)


%% Prepare code block
clc;
clear;
close all;


%% Initialize variables
start_CMD = [0x4F,0x50,0xFF,0xC0,0x45,0x44];

global data_raw;
global uart_flag;
data_raw = zeros(1,62*4);
uart_flag = 0;

LA_params = zeros(4,3);
Anchors_raw_data = zeros(62, 4, 'uint8');
Anchors_rssi_data = zeros(50, 4, 'int8');                                   % must be signed variable
Filter_return = zeros(4, 2);
weyman_data = zeros(248,1, 'uint8');


%% Initialize common components
pause('on');                                                                % enable a delay func
serialhandle = serialport("COM4",115200);                                  % create serialport object
configureCallback(serialhandle, "byte", 62*4, @weyman_readserial);


%% Communicate with WSN coordinator
write(serialhandle,start_CMD,"uint8");
flush(serialhandle);                                                        % clear serialport stack
while 1                                                                     % self-adapt time delay to wait WSN collect RSSI data
    if uart_flag == 1
        break; 
    else
        pause(1);
    end
end
weyman_data = data_raw';                                                    % switch to column data 

%% Matrix build

% Anchor1 = struct('raw_data', 'rssi_data', 'coordx', 'coordy');
% Anchor2 = struct('raw_data', 'rssi_data', 'coordx', 'coordy');
% Anchor3 = struct('raw_data', 'rssi_data', 'coordx', 'coordy');
% Anchor4 = struct('raw_data', 'rssi_data', 'coordx', 'coordy');

Anchors_raw_data(:, 1) = weyman_data(1:62, 1);
Anchors_raw_data(:, 2) = weyman_data(63:124, 1);
Anchors_raw_data(:, 3) = weyman_data(125:186, 1);
Anchors_raw_data(:, 4) = weyman_data(187:248, 1);

% Anchors_rssi_data(:, 1) = Anchors_raw_data(11:60, 1);
% Anchors_rssi_data(:, 2) = Anchors_raw_data(11:60, 2);
% Anchors_rssi_data(:, 3) = Anchors_raw_data(11:60, 3);
% Anchors_rssi_data(:, 4) = Anchors_raw_data(11:60, 4);

Anchors_rssi_data(:, 1) = 1 + typecast(Anchors_raw_data(11:60, 1), 'int8');
Anchors_rssi_data(:, 2) = 1 + typecast(Anchors_raw_data(11:60, 2), 'int8');
Anchors_rssi_data(:, 3) = 1 + typecast(Anchors_raw_data(11:60, 3), 'int8');
Anchors_rssi_data(:, 4) = 1 + typecast(Anchors_raw_data(11:60, 4), 'int8');
Anchors_rssi_data = double(Anchors_rssi_data);


Anchors_coordx = Anchors_raw_data(9,:)';
Anchors_coordy = Anchors_raw_data(10,:)';

save('weymantest.mat','Anchors_raw_data');                                  % save all 4 anchors raw data


%% Run filter algorithm
cd ../Filter
% % Kalman Filter
% cd 'Kalman_fliter'
% [Filter_return(1,1),Filter_return(1,2)] = ...
%     kalman_fliter_func(Anchors_rssi_data(:,1), 50, 0.01, 4);                % attention observe covarience
% 
% [Filter_return(2,1),Filter_return(2,2)] = ...
%     kalman_fliter_func(Anchors_rssi_data(:,2), 50, 0.01, 4);
% 
% [Filter_return(3,1),Filter_return(3,2)] = ...
%     kalman_fliter_func(Anchors_rssi_data(:,3), 50, 0.01, 4);
% 
% [Filter_return(4,1),Filter_return(4,2)] = ...
%     kalman_fliter_func(Anchors_rssi_data(:,4), 50, 0.01, 4);
% cd ..

% % Average Filter
% cd 'Average Filter'
% [Filter_return(1,1),Filter_return(1,2)] = ...
%     MovingAverageFunc(Anchors_rssi_data(:,1)', 3);
% 
% [Filter_return(2,1),Filter_return(2,2)] = ...
%     MovingAverageFunc(Anchors_rssi_data(:,2)', 3);
% 
% [Filter_return(3,1),Filter_return(3,2)] = ...
%     MovingAverageFunc(Anchors_rssi_data(:,3)', 3);
% 
% [Filter_return(4,1),Filter_return(4,2)] = ...
%     MovingAverageFunc(Anchors_rssi_data(:,4)', 3);
% cd ..

% Gaussian Filter, can not use in 20220527
cd 'Gaussian_fliter'
[Filter_return(1,1),Filter_return(1,2)] = ...
    GaussianFunc(Anchors_rssi_data(:,1)', 2, 3, 2);                         % attention function arguement 

[Filter_return(2,1),Filter_return(2,2)] = ...
    GaussianFunc(Anchors_rssi_data(:,2)', 2, 3, 2);                         

[Filter_return(3,1),Filter_return(3,2)] = ...
    GaussianFunc(Anchors_rssi_data(:,3)', 2, 3, 2);                        

[Filter_return(4,1),Filter_return(4,2)] = ...
    GaussianFunc(Anchors_rssi_data(:,4)', 2, 3, 2);                        
cd ..

cd ../Localization_test_2


%% Math model calculate distance
arg = readmatrix('MathModel/mathmodel_argument.txt','OutputType','double');
A = arg(1);
n = arg(2);

dist1 = power(10, (A-Filter_return(1,1))./(10*n));                          % shadow model
dist2 = power(10, (A-Filter_return(2,1))./(10*n)); 
dist3 = power(10, (A-Filter_return(3,1))./(10*n)); 
dist4 = power(10, (A-Filter_return(4,1))./(10*n)); 


%% Initialize localization algorithm input data matrix
LA_params(:,1) = Anchors_coordx;
LA_params(:,2) = Anchors_coordy;
LA_params(:,3) = [dist1; dist2; dist3; dist4];


%% Run localization algorithm
cd ..
%cd Centroid;
%Centroid(20,0.9);
%Centroid_second(20,0.9);
%Centroid_third(20,0.9);
cd RSSI;
%RSSI;
%RSSI_second;
%RSSI_third;
UK_coord = weyman_RSSI_LS(LA_params);
cd ../Localization_test_2

%% Error analyze and figure plot
fprintf('Algorithm calculate the unknown node is at (%.4f,%.4f)\n', UK_coord);
fprintf('Flow done, congraduations!\n');
plot(Anchors_coordx, Anchors_coordy, 'r^', 'MarkerFaceColor', 'r');
hold on;
scatter(UK_coord(1),UK_coord(2), 'bo', 'MarkerFaceColor', 'b');



%% Appendix: inter function here
function weyman_readserial(serialhandle,~)

global data_raw uart_flag;

data_raw = read(serialhandle, 62*4, "uint8");                                 % read a group of RSSI data 
% configureCallback(serialhandle, "off");                                   % finish one read serialport, close callback
flush(serialhandle);                                                      % clear serialport stack
uart_flag =  1;

return;

end

