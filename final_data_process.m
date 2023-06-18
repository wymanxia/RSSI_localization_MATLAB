% % File name:        final_data_process
% % Create date:      2022.12.22
% % Writer:           Weyman 
% % Brief:            final paper data process script and save
% % Latest change:    2022.12.22
% % Change note:      Create


%% Prepare Work
clc;
clear;
close all;

%% File path prepare
path = strcat(pwd,'\*.mat');
dir_output = dir(path);
mat_data_filename = {dir_output.name};

% init dynamic cell/array
coord = [];    
coord_xlsx = {};        
Average_UK_coord_xlsx = {};
Gaussian_UK_coord_xlsx = {};
Kalman_UK_coord_xlsx = {};
Average_error_xlsx = {};
Gaussian_error_xlsx = {};
Kalman_error_xlsx = {};

Average_LA_params = zeros(4,3);
Kalman_LA_params = zeros(4,3);
Gaussian_LA_params = zeros(4,3);

Anchors_rssi_data = zeros(50, 4, 'int8');                                   % must be signed variable


%% Traversal filename cell
for i = 1:length(mat_data_filename)
    
    filename_str = cell2mat(mat_data_filename(1,i));
    filename_str = filename_str(1:end-4);       % remove the file type
    coord_str_split = split(filename_str, '_');     % split the string 
    coord = [coord; str2double(coord_str_split(1)) str2double(coord_str_split(2))];     % dynamic array increase
    
end

coord = coord .* repmat(0.01, length(mat_data_filename), 2);        % switch to true coordinate

%% Run the algorithm once a cycle
for i = 1:length(mat_data_filename)
    
    load(cell2mat(mat_data_filename(1,i)), '-mat');
    
    Anchors_rssi_data(:, 1) = 1 + typecast(Anchors_raw_data_temp(11:60, 1), 'int8');
    Anchors_rssi_data(:, 2) = 1 + typecast(Anchors_raw_data_temp(11:60, 2), 'int8');
    Anchors_rssi_data(:, 3) = 1 + typecast(Anchors_raw_data_temp(11:60, 3), 'int8');
    Anchors_rssi_data(:, 4) = 1 + typecast(Anchors_raw_data_temp(11:60, 4), 'int8');
    
    Anchors_coordx = [Anchors_raw_data_temp(9,:)'];
    Anchors_coordy = [Anchors_raw_data_temp(10,:)'];
    
    arg = readmatrix('MathModel/mathmodel_argument.txt','OutputType','double');
    A = arg(1);
    n = arg(2);
    
    cd Filter
    cd Average_fliter
    [Average_Filter_return(1,1),Average_Filter_return(1,2)] = ...
        MovingAverageFunc(Anchors_rssi_data(:,1)', 3);
    
    [Average_Filter_return(2,1),Average_Filter_return(2,2)] = ...
        MovingAverageFunc(Anchors_rssi_data(:,2)', 3);
    
    [Average_Filter_return(3,1),Average_Filter_return(3,2)] = ...
        MovingAverageFunc(Anchors_rssi_data(:,3)', 3);
    
    [Average_Filter_return(4,1),Average_Filter_return(4,2)] = ...
        MovingAverageFunc(Anchors_rssi_data(:,4)', 3);
    
    dist1 = power(10, (A-Average_Filter_return(1,1))./(10*n));                          % shadow model
    dist2 = power(10, (A-Average_Filter_return(2,1))./(10*n));
    dist3 = power(10, (A-Average_Filter_return(3,1))./(10*n));
    dist4 = power(10, (A-Average_Filter_return(4,1))./(10*n));
    
    Average_LA_params(:,1) = Anchors_coordx;
    Average_LA_params(:,2) = Anchors_coordy;
    Average_LA_params(:,3) = [dist1; dist2; dist3; dist4];
    cd ..
    
    cd Gaussian_fliter
    [Gaussian_Filter_return(1,1),Gaussian_Filter_return(1,2)] = ...
        GaussianFunc(double(Anchors_rssi_data(:,1)'), 2, 3, 2);                         % attention function arguement
    
    [Gaussian_Filter_return(2,1),Gaussian_Filter_return(2,2)] = ...
        GaussianFunc(double(Anchors_rssi_data(:,2)'), 2, 3, 2);
    
    [Gaussian_Filter_return(3,1),Gaussian_Filter_return(3,2)] = ...
        GaussianFunc(double(Anchors_rssi_data(:,3)'), 2, 3, 2);
    
    [Gaussian_Filter_return(4,1),Gaussian_Filter_return(4,2)] = ...
        GaussianFunc(double(Anchors_rssi_data(:,4)'), 2, 3, 2); 
    
    dist1 = power(10, (A-Gaussian_Filter_return(1,1))./(10*n));                          % shadow model
    dist2 = power(10, (A-Gaussian_Filter_return(2,1))./(10*n));
    dist3 = power(10, (A-Gaussian_Filter_return(3,1))./(10*n));
    dist4 = power(10, (A-Gaussian_Filter_return(4,1))./(10*n));
    
    Gaussian_LA_params(:,1) = Anchors_coordx;
    Gaussian_LA_params(:,2) = Anchors_coordy;
    Gaussian_LA_params(:,3) = [dist1; dist2; dist3; dist4];
    cd ..
    
    cd Kalman_fliter
    [Kalman_Filter_return(1,1),Kalman_Filter_return(1,2)] = ...
        kalman_fliter_func(Anchors_rssi_data(:,1), 50, 0.01, 4);                % attention observe covarience
    
    [Kalman_Filter_return(2,1),Kalman_Filter_return(2,2)] = ...
        kalman_fliter_func(Anchors_rssi_data(:,2), 50, 0.01, 4);
    
    [Kalman_Filter_return(3,1),Kalman_Filter_return(3,2)] = ...
        kalman_fliter_func(Anchors_rssi_data(:,3), 50, 0.01, 4);
    
    [Kalman_Filter_return(4,1),Kalman_Filter_return(4,2)] = ...
        kalman_fliter_func(Anchors_rssi_data(:,4), 50, 0.01, 4);
    
    dist1 = power(10, (A-Kalman_Filter_return(1,1))./(10*n));                          % shadow model
    dist2 = power(10, (A-Kalman_Filter_return(2,1))./(10*n));
    dist3 = power(10, (A-Kalman_Filter_return(3,1))./(10*n));
    dist4 = power(10, (A-Kalman_Filter_return(4,1))./(10*n));
    
    Kalman_LA_params(:,1) = Anchors_coordx;
    Kalman_LA_params(:,2) = Anchors_coordy;
    Kalman_LA_params(:,3) = [dist1; dist2; dist3; dist4];
    cd ..       % back to Filter
    cd ..       % back to dir localization_xxxxxxxx
    
    cd RSSI
    Average_UK_coord = weyman_RSSI_LS(Average_LA_params);
    Gaussian_UK_coord = weyman_RSSI_LS(Gaussian_LA_params);
    Kalman_UK_coord = weyman_RSSI_LS(Kalman_LA_params);
    cd ..
    
    % calculate error
    average_error = sqrt((Average_UK_coord(1, 1)-coord(i, 1))^2 + ...
        (Average_UK_coord(2, 1)-coord(i, 2))^2);
    gaussian_error = sqrt((Gaussian_UK_coord(1, 1)-coord(i, 1))^2 + ...
        (Gaussian_UK_coord(2, 1)-coord(i, 2))^2);
    kalman_error = sqrt((Kalman_UK_coord(1, 1)-coord(i, 1))^2 + ...
        (Kalman_UK_coord(2, 1)-coord(i, 2))^2);
    
    
    
    Average_UK_coord_xlsx = [Average_UK_coord_xlsx; ...
        strcat('(', ...
        mat2str(Average_UK_coord(1, 1),6),...
        ',', ...
        mat2str(Average_UK_coord(2, 1),6),...
        ')')];      % append result string into xlsx write buffer cell
    Average_error_xlsx = [Average_error_xlsx; mat2str(average_error,6)];      % append error string into xlsx write buffer cell
    
    
    Gaussian_UK_coord_xlsx = [Gaussian_UK_coord_xlsx; ...
        strcat('(', ...
        mat2str(Gaussian_UK_coord(1, 1),6),...
        ',', ...
        mat2str(Gaussian_UK_coord(2, 1),6),...
        ')')];      % append result string into xlsx write buffer cell
    Gaussian_error_xlsx = [Gaussian_error_xlsx; mat2str(gaussian_error,6)];      % append error string into xlsx write buffer cell
    
    Kalman_UK_coord_xlsx = [Kalman_UK_coord_xlsx; ...
        strcat('(', ...
        mat2str(Kalman_UK_coord(1, 1),6),...
        ',', ...
        mat2str(Kalman_UK_coord(2, 1),6),...
        ')')];      % append result string into xlsx write buffer cell
    Kalman_error_xlsx = [Kalman_error_xlsx; mat2str(kalman_error,6)];      % append error string into xlsx write buffer cell
    
    
    
    
    coord_xlsx = [coord_xlsx; ...
        strcat('(', ...
        mat2str(coord(i, 1)),...
        ',', ...
        mat2str(coord(i, 2)),...
        ')')];      % append true coordinate string into xlsx write buffer cell
    
    
    
end



%% Result write excel
% write title 
writematrix('average', 'result.xlsx', 'Sheet',1, 'Range','B1');
writematrix('gaussian', 'result.xlsx', 'Sheet',1, 'Range','D1');
writematrix('kalman', 'result.xlsx', 'Sheet',1, 'Range','F1');

writematrix('average_error', 'result.xlsx', 'Sheet',1, 'Range','C1');
writematrix('gaussian_error', 'result.xlsx', 'Sheet',1, 'Range','E1');
writematrix('kalman_error', 'result.xlsx', 'Sheet',1, 'Range','G1');

writecell(coord_xlsx, 'result.xlsx','Sheet',1, 'Range', 'A2');
writecell(Average_UK_coord_xlsx, 'result.xlsx','Sheet',1, 'Range', 'B2');
writecell(Average_error_xlsx, 'result.xlsx','Sheet',1, 'Range', 'C2');

writecell(Gaussian_UK_coord_xlsx, 'result.xlsx','Sheet',1, 'Range', 'D2');
writecell(Gaussian_error_xlsx, 'result.xlsx','Sheet',1, 'Range', 'E2');

writecell(Kalman_UK_coord_xlsx, 'result.xlsx','Sheet',1, 'Range', 'F2');
writecell(Kalman_error_xlsx, 'result.xlsx','Sheet',1, 'Range', 'G2');





