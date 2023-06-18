function [GaussianWeightAverage,remained] = GaussianFunc(input_data, gaussian_data_sigma, windowPoint, gaussian_window_sigma, varargin)
% Brief:   本函数用于实现对RSSI测量的一维数据的高斯滤波
% Arg:     input_data - 输入的一维数据矩阵（向量）
%          gaussian_data_sigma - 高斯分布算子的标准差，决定最终计算高斯加权
%                                均值的各数据点权重大小
%          windowPoint - 高斯滤波核（窗）的宽度，即离散窗的半径（包括）中心
%                        点，必须是奇数。窗口的数据点数目为2*windowPoint-1
%          gaussian_window_sigma - 滑动窗口中“附近”值的权重大小，按照高斯
%                                  分布给出。
%          varargin - vary-length argument to achieve option 'plot figure'
% Writter: Weyman Xia
% Date:    20220328
%          20220610(v.1 estimated)
%          20221027(v.2 added varargin to achieve 'plot figure' option)


%% local variables initialization
x = input_data;
x_length = length(x); 
window_sigma = gaussian_window_sigma;
data_sigma = gaussian_data_sigma;
r = windowPoint;
t = linspace(1,x_length,x_length);      


%% filter raw data
for i = 1 : r*2-1
    GaussianDistribute(i) = exp(-(i-r)^2/(2*window_sigma^2))/(window_sigma*sqrt(2*pi));
end
GaussianTemp = GaussianDistribute/sum(GaussianDistribute);      % 权重归一化

y = x;
for i = r : x_length-r
    y(1,i) = y(1,i-r+1 : i+r-1)*GaussianTemp';
end


% %% plot the resault
% figure;
% plot(t,x,'-o','LineWidth',1.5)
% hold on
% plot(t,y,'-+','LineWidth',1.5)
% title('Gaussian Filter');
% xlabel('Data Num');
% ylabel('Data Value');
% legend('Raw Data','Filtered Data')


%% fresh return value
y_average = sum(y)/length(y);
for j = 1:length(y)
  yGaussianDistribute(j) = exp(-(y(j)-y_average)^2/(2*data_sigma^2))/(data_sigma*sqrt(2*pi));
end
yGaussianTemp = yGaussianDistribute/sum(yGaussianDistribute);      % 权重归一化

GaussianWeightAverage = y*yGaussianTemp';
remained = data_sigma;

%% plot the resault if needed 
varargin_len = length(varargin);
if  varargin_len
    if varargin{1} == 'plot figure'
    figure;
    plot(t,x,'-o','LineWidth',1.5)
    hold on
    plot(t,y,'-+','LineWidth',1.5)
    title('Gaussian Filter');
    xlabel('Data Num');
    ylabel('Data Value');
    legend('Raw Data','Filtered Data')
    end
end



end

