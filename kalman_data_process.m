% % File name:        hysteresis_data_process
% % Create date:      2023.3.17
% % Writer:           Weyman 
% % Brief:            Offline localization data process in actual experiment
% % Latest change:    2023.3.17
% % Change note:      Only do the kalman filter and run the algorithm, need
% %                   to save data manually
% %                   


%% Prepare Work
clc;
clear;
close all;

%% Variables Initialization
LA_params = zeros(4,3);
Anchors_rssi_data = zeros(50, 4, 'int8');                                   % must be signed variable
filename = "200_100_4.mat";                                                 % change this variable when choose different localization data


%% Import data & Matrix date prepare
load(filename, '-mat');                                                     % only process .mat data
filename_str = cell2mat(filename);
filename_str = filename_str(1:end-4);                                       % remove the file type
coord_str_split = split(filename_str, '_');                                 % split the string
coord = [str2double(coord_str_split(1)) str2double(coord_str_split(2))];    % dynamic array increase
coord = coord .* 0.01;                                                      % switch to true coordinate


Anchors_rssi_data(:, 1) = 1 + typecast(Anchors_raw_data_temp(11:60, 1), 'int8');
Anchors_rssi_data(:, 2) = 1 + typecast(Anchors_raw_data_temp(11:60, 2), 'int8');
Anchors_rssi_data(:, 3) = 1 + typecast(Anchors_raw_data_temp(11:60, 3), 'int8');
Anchors_rssi_data(:, 4) = 1 + typecast(Anchors_raw_data_temp(11:60, 4), 'int8');

Anchors_rssi_data = double(Anchors_rssi_data);

Anchors_coordx = Anchors_raw_data_temp(9,:)';
Anchors_coordy = Anchors_raw_data_temp(10,:)';

arg = readmatrix('MathModel/mathmodel_argument.txt','OutputType','double');
A = arg(1);
n = arg(2);


%% Data Filtering
cd Filter
cd 'Kalman_fliter'
[Filter_return(1,1),Filter_return(1,2)] = ...
    kalman_fliter_func(Anchors_rssi_data(:,1), 50, 0.01, 4);                % attention observe covarience

[Filter_return(2,1),Filter_return(2,2)] = ...
    kalman_fliter_func(Anchors_rssi_data(:,2), 50, 0.01, 4);

[Filter_return(3,1),Filter_return(3,2)] = ...
    kalman_fliter_func(Anchors_rssi_data(:,3), 50, 0.01, 4);

[Filter_return(4,1),Filter_return(4,2)] = ...
    kalman_fliter_func(Anchors_rssi_data(:,4), 50, 0.01, 4);
cd ../..


%% Distance Switch & LLS Argument Prepare
dist1 = power(10, (A-Filter_return(1,1))./(10*n));                          % shadow model
dist2 = power(10, (A-Filter_return(2,1))./(10*n)); 
dist3 = power(10, (A-Filter_return(3,1))./(10*n)); 
dist4 = power(10, (A-Filter_return(4,1))./(10*n)); 

LA_params(:,1) = Anchors_coordx;
LA_params(:,2) = Anchors_coordy;
LA_params(:,3) = [dist1; dist2; dist3; dist4];

%% Prepare WLS weight vector
distance_vector_kalman = [dist1 dist2 dist3 dist4];                         % set the kalman filter distance weight vector
distance_vector_kalman = 1 ./ distance_vector_kalman;
distance_vector_kalman = normalize(distance_vector_kalman, 'norm', 1);

for j = 1:4
    Anchors_rssi_var(1,j) = var(double(Anchors_rssi_data(:,j)));            % rssi variance
end
variance_vector = Anchors_rssi_var;
variance_vector = 1 ./ variance_vector;                                     % variance and distance influence the error in reverse mapping
variance_vector = normalize(variance_vector, 'norm', 1);                    % normalize the weight vector in 1-norm

weight_factor = 0.5;                                                        % set the factor(const) of two element influencing the weight
weight_vector_kalman = weight_factor * variance_vector + (1-weight_factor) * distance_vector_kalman;


%% Localization Algorithm
cd RSSI;
UK_coord = weyman_RSSI_LS(LA_params);
localization_error = sqrt((UK_coord(1, 1)-coord(1, 1))^2 + ...
    (UK_coord(2, 1)-coord(1, 2))^2);

UK_coord_wls = RSSI_WLS(LA_params, weight_vector_kalman);
localization_error_wls = sqrt((UK_coord_wls(1, 1)-coord(1, 1))^2 + ...
    (UK_coord_wls(2, 1)-coord(1, 2))^2);
cd ..


%% Error Analyze & Figure Plot
fprintf('LLS algorithm calculate the unknown node is at (%.4f,%.4f)\n', UK_coord);
fprintf('LLS localization error is %.4f\n', localization_error);
fprintf('WLS algorithm calculate the unknown node is at (%.4f,%.4f)\n', UK_coord_wls);
fprintf('WLS localization error is %.4f\n', localization_error_wls);
fprintf('Flow done, congraduations!\n');










