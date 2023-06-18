% % File name:        hysteresis_data_process
% % Create date:      2022.10.26
% % Writer:           Weyman 
% % Brief:            Offline localization data process in actual experiment
% % Latest change:    2022.11.9
% % Change note:      Add datatype switch code to Anchors_rssi_data(from 
% %                   int8 to double)


%% Prepare Work
clc;
clear;
close all;

%% Variables Initialization
LA_params = zeros(4,3);
Anchors_rssi_data = zeros(50, 4, 'int8');                                   % must be signed variable


%% Import data & Matrix date prepare
load('250_250_x.mat', '-mat');

Anchors_rssi_data(:, 1) = 1 + typecast(Anchors_raw_data(11:60, 1), 'int8');
Anchors_rssi_data(:, 2) = 1 + typecast(Anchors_raw_data(11:60, 2), 'int8');
Anchors_rssi_data(:, 3) = 1 + typecast(Anchors_raw_data(11:60, 3), 'int8');
Anchors_rssi_data(:, 4) = 1 + typecast(Anchors_raw_data(11:60, 4), 'int8');

Anchors_rssi_data = double(Anchors_rssi_data);

Anchors_coordx = Anchors_raw_data(9,:)';
Anchors_coordy = Anchors_raw_data(10,:)';

arg = readmatrix('MathModel/mathmodel_argument.txt','OutputType','double');
A = arg(1);
n = arg(2);


%% Data Filtering
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


%% Distance Switch & LLS Argument Prepare
dist1 = power(10, (A-Filter_return(1,1))./(10*n));                          % shadow model
dist2 = power(10, (A-Filter_return(2,1))./(10*n)); 
dist3 = power(10, (A-Filter_return(3,1))./(10*n)); 
dist4 = power(10, (A-Filter_return(4,1))./(10*n)); 

LA_params(:,1) = Anchors_coordx;
LA_params(:,2) = Anchors_coordy;
LA_params(:,3) = [dist1; dist2; dist3; dist4];


%% Localization Algorithm
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


%% Error Analyze & Figure Plot
fprintf('Algorithm calculate the unknown node is at (%.4f,%.4f)\n', UK_coord);
fprintf('Flow done, congraduations!\n');
plot(Anchors_coordx, Anchors_coordy, 'r^', 'MarkerFaceColor', 'r');
hold on;
scatter(UK_coord(1),UK_coord(2), 'bo', 'MarkerFaceColor', 'b');









