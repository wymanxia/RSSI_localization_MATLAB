function [Result,ResultError] = kalman_fliter_func(RSSI_Data, DataLength, ProceessErrorQ, ObserveErrorR, varargin)
% Brief:   本函数用于实现RSSI测量系统的卡尔曼滤波
% Detail:  由于系统简单且是一维数据的直接观测，故系统的观测矩阵和状态
%          转移矩阵均为简化的1（单位阵），该卡尔曼滤波函数不具有通用性，需
%          注意。
% Arg:     RSSI_Data - the matrix of RSSI data in row vector
%          DataLength - the numbers of RSSI
%          ProceessErrorQ - process error in gasussian distribution
%          ObserveErrorR - observe error in gasussian distribution
%          varargin - vary-length argument to achieve option 'plot figure'
% Writter: Weyman Xia
% Date:    20220204
%          20221027 - v.2 added varargin to achieve 'plot figure' option
%          20230220 - v.3 change the process noise and measure noise
%                         equation
%          20230317 - v.4 cancel the process/measure nosie simulation
%                         




%% variables initialization
N = DataLength;
Xest = zeros(1,N);      % represent RSSI kalman fliter estimate value
Xobs = zeros(1,N);      % represent RSSI observe value, have noise part
Xstate = zeros(1,N);    % represent RSSI state change value, have noise part
Peste = zeros(1,N);     % represent system state error value 
Xin = zeros(1,N);       % input RSSI data, actually from func arg

%% error parameters initialization
Q = ProceessErrorQ;
R = ObserveErrorR;
% W = sqrt(Q)*randn(1,N);                                                   % simulate a process gaussian noise 
% V = sqrt(R)*randn(1,N);                                                   % simulate a mearsure gaussian nosie 

% W = normrnd(0, sqrt(Q), 1, N);                                              % simulate a process gaussian noise 
% V = normrnd(0, sqrt(R), 1, N);                                              % simulate a mearsure gaussian nosie 

W = zeros(1, N);                                                            % real RSSI data already have process noise
V = zeros(1, N);                                                            % real RSSI data already have measure noise 


%% algorithm parameters initialization
A = 1;      % system state switch matrix
G = 1;      % data observation matrix
I = eye(1);

%% first cycle variable initialization
Xin = RSSI_Data;
Peste(1) = Q;
Xstate(1) = Xin(1);
Xest(1) = Xstate(1);

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

%% output variables set 
Result = Xest(N);
ResultError = Peste(DataLength);

%% draw figure if needed
varargin_len = length(varargin);
if  varargin_len
    if varargin{1} == 'plot figure'
    figure;
    plot(linspace(1,DataLength,DataLength),Xin,'-o','LineWidth',1.5);
    hold on;
    plot(linspace(1,DataLength,DataLength),Xest,'-+','LineWidth',1.5);
    title('Kalman Filter');
    xlabel('Data Num');
    ylabel('Data Value');
    legend('Raw data','Filtered Data');
    
    figure;
    plot(linspace(1,DataLength,DataLength), Kg);
    title('Kalman Factor');

    
    end
end



end

