% % File name:        final_data_process_wls
% % Create date:      2023.1.3
% % Writer:           Weyman 
% % Brief:            final paper data process script and save using wls
% % Latest change:    2023.1.4
% % Change note:      add weight matrix element acquire from variance and 
% %                   distance


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
Anchors_rssi_var = zeros(1, 4, 'double');           % variance of each anchors raw


%% Traversal filename cell
for i = 1:length(mat_data_filename)
    
    filename_str = cell2mat(mat_data_filename(1,i));
    filename_str = filename_str(1:end-4);       % remove the file type
    coord_str_split = split(filename_str, '_');     % split the string 
    coord = [coord; str2double(coord_str_split(1)) str2double(coord_str_split(2))];     % dynamic array increase
    
end

coord = coord .* repmat(0.01, length(mat_data_filename), 2);        % switch to true coordinate

% Run the algorithm once a cycle
for i = 1:length(mat_data_filename)
    
    %% offline data load
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
    
    
    %% data filter
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
    
    distance_vector_average = [dist1 dist2 dist3 dist4];            % set the average filter distance weight vector
    distance_vector_average = 1 ./ distance_vector_average;
    distance_vector_average = normalize(distance_vector_average, 'norm', 1);
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
    
    distance_vector_gaussian = [dist1 dist2 dist3 dist4];            % set the gaussian filter distance weight vector
    distance_vector_gaussian = 1 ./ distance_vector_gaussian;
    distance_vector_gaussian = normalize(distance_vector_gaussian, 'norm', 1);
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
    
    distance_vector_kalman = [dist1 dist2 dist3 dist4];            % set the kalman filter distance weight vector
    distance_vector_kalman = 1 ./ distance_vector_kalman;
    distance_vector_kalman = normalize(distance_vector_kalman, 'norm', 1);
    cd ..       % back to Filter
    cd ..       % back to dir localization_xxxxxxxx
    
    
    %% wls data prepare, distance weight vector code after related filter
    for j = 1:4
        Anchors_rssi_var(1,j) = var(double(Anchors_rssi_data(:,j)));            % rssi variance
    end
    
    variance_vector = Anchors_rssi_var;
    variance_vector = 1 ./ variance_vector;         % variance and distance influence the error in reverse mapping
    variance_vector = normalize(variance_vector, 'norm', 1);            % normalize the weight vector in 1-norm

    weight_factor = 0.5;            % set the factor(const) of two element influencing the weight
    weight_vector_average = weight_factor * variance_vector + (1-weight_factor) * distance_vector_average;
    weight_vector_gaussian = weight_factor * variance_vector + (1-weight_factor) * distance_vector_gaussian;
    weight_vector_kalman = weight_factor * variance_vector + (1-weight_factor) * distance_vector_kalman;

    
    %% localization algorithm
    cd RSSI
    Average_UK_coord = RSSI_WLS(Average_LA_params, weight_vector_average);          % call algorithm function
    Gaussian_UK_coord = RSSI_WLS(Gaussian_LA_params, weight_vector_gaussian);
    Kalman_UK_coord = RSSI_WLS(Kalman_LA_params, weight_vector_kalman);
    cd ..
    
    %% calculate error
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
% write lls data
writematrix('average', 'result_wls.xlsx', 'Sheet',1, 'Range','B1');
writematrix('gaussian', 'result_wls.xlsx', 'Sheet',1, 'Range','D1');
writematrix('kalman', 'result_wls.xlsx', 'Sheet',1, 'Range','F1');

writematrix('average_error', 'result_wls.xlsx', 'Sheet',1, 'Range','C1');
writematrix('gaussian_error', 'result_wls.xlsx', 'Sheet',1, 'Range','E1');
writematrix('kalman_error', 'result_wls.xlsx', 'Sheet',1, 'Range','G1');

writecell(coord_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'A2');
writecell(Average_UK_coord_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'B2');
writecell(Average_error_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'C2');

writecell(Gaussian_UK_coord_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'D2');
writecell(Gaussian_error_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'E2');

writecell(Kalman_UK_coord_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'F2');
writecell(Kalman_error_xlsx, 'result_wls.xlsx','Sheet',1, 'Range', 'G2');







