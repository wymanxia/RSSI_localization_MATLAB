% function: this is a kalman fliter function test %
% writer: weyman xia                              %
% date: 20220126                                  %

% here comes initialization
clc;
clear all;
close all;
N = 20;     % set the number of data, actually use need to set in func arg


% create variables
Xest = zeros(1,N);      % represent RSSI kalman fliter estimate value
Xobs = zeros(1,N);      % represent RSSI observe value, have noise part
Xstate = zeros(1,N);    % represent RSSI state change value, have noise part
Peste = zeros(1,N);       % represent system state error value 
Xin = zeros(1,N);       % input RSSI data, actually from func arg

% initialize variables
% first initialize the noise variables
Q = 0.01;       % Q作为状态转移方程中的高斯分布误差的协方差，表示系统过程噪声，使用时应从实参中获取
R = 0.25;       % R作为观测方程中的高斯分布误差的协方差，表示测量噪声，使用时应该从函数实参中获取
W = sqrt(Q)*randn(1,N);     % simulate a process gaussian noise 
V = sqrt(R)*randn(1,N);     % simulate a mearsure gaussian nosie 

% second initialize the system constant variables
A = 1;
G = 1;
I = eye(1);

% third initialize the simulate variables, actual value from func arg
Xin = [-50 -51 -50.6 -49.5 -50.5 -50 -49 -51 -50.5 -49.5 -50 -51 -49 -50 -50.5 -49 -49 -49 -50 -50];
Peste(1) = Q;
Xstate(1) = Xin(1);
Xest(1) = Xstate(1);

% 进行卡尔曼滤波RSSI值，假设理论的RSSI值为50。
% 注意由于测量RSSI使用卡尔曼滤波的特殊性，实际上每一次卡尔曼迭代均是求出了概率
% 上方差最小最接近理论值的真实值，这是一个迭代优化的过程，使用迭代算法后最后输
% 出的 Xest 值即可认为是最优值，并且给出了该最优值下的高斯分布参数。

for k = 2:N
    
    % 通过系统状态转换的预测方程进行估算及估算值的协方差计算
    Xstate(k) = A*Xest(k-1)+W(k-1);
    Pse = A*Peste(k-1)*A'+Q;       % 此处的Pse仅是一个中间值用于计算卡尔曼系数,表示系统状态转移估测数据的误差度量
    
    % 将理想的RSSI值添加高斯分布的观测噪声
    Xobs(k) = G*Xin(k)+V(k);
    
    % 通过权重设计修正方程及卡尔曼系数和误差计算
    Kg(k) = Pse*G'*inv(G*Pse*G'+R);
    Xest(k) = Xstate(k)+Kg(k)*(Xobs(k)-G*Xstate(k));        % 括号内观测矩阵乘状态量未带误差的原因是数学推导出来的
    Peste(k) = (I-Kg(k)*G)*Pse;
      
end

% show the calculate result in figure 
plot(linspace(1,20,20),Xest,'-o',linspace(1,20,20),Xin,'-*');








