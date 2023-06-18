function [filtered,remained] = MovingAverageFunc(input_data,input_windowsize, varargin)
% Brief:   本函数用于实现对RSSI测量的一维数据的加窗均值滤波
% Arg:     input_data - 输入的一维数据矩阵（向量）
%          input_windowsize - 使用的窗口大小（矩形窗，归一化）
%          varargin - vary-length argument to achieve option 'plot figure'
% Writter: Weyman Xia
% Date:    20220328 - 20220528(estimated ver 1.1)
%          20221027 - v.2 added varargin to achieve 'plot figure' option


%% local variables initialization
x = input_data;
x_length = length(x);
windowSize = input_windowsize;

%% prepare algorithm parameters and run algorithm
t = linspace(1,x_length,x_length);
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y = filter(b,a,x);
y(1,1:input_windowsize) = input_data(1,1:input_windowsize);


%% output resault
remained = input_windowsize;
filtered = sum(y)/length(y);


%% plot resault if needed
varargin_len = length(varargin);
if  varargin_len
    if varargin{1} == 'plot figure'
    figure;
    plot(t,x,'marker','o','LineWidth',1.5)
    hold on
    plot(t,y,'marker','+','LineWidth',1.5)
    title('Moving Mean Filter');
    xlabel('Data Num');
    ylabel('Data Value');
    legend('Raw Data','Filtered Data')
    end
end

end

