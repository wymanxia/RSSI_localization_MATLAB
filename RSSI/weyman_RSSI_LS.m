function UKnode_coord = weyman_RSSI_LS(anchor_matrix)
% Brief:   本函数用于使用RSSI得出的数据进行定位算法
% Detail:  函数名近似和其他原因(懒)，这里的算法内容和其他几个RSSI函数不同。
%          本函数主要用于weyman_all_flow的流程计算，和本文件夹下其他函数区
%          别在于直接调用了通过WSN实物得到的节点坐标数据和RSSI转化成距离d后
%          的数据，函数内容只包含了使用最小二乘法(LS)进行定位计算的内容。
%          不要添加到run.m中去跑
% Arg:     anchor_matrix - 包含所有锚节点坐标信息(x,y)及与未知节点间等效距
%          离d的矩阵
% Return:  UKnode_coord - 未知节点的坐标
% Writter: Weyman Xia
% Date:    20220317





%% 选取最近锚节点方程降次用于WLS
[min_d, index] = min(anchor_matrix(:,3));          % 获取用于降次的锚节点方程
anchor_d = anchor_matrix(:,3);
anchor_coord = anchor_matrix(:,1:2);
liner_dim = length(anchor_coord');          % 降次后的超定方程组维度

A = 2 * (anchor_coord - repmat(anchor_coord(index,:),liner_dim,1));
anchor_coord_square_sum = transpose(sum(transpose(anchor_coord.^2)));      
dist_square = anchor_d.^2;      
b = anchor_coord_square_sum - ...
    repmat(anchor_coord_square_sum(index), liner_dim, 1 )- ...
    dist_square + ...
    repmat(dist_square(index), liner_dim, 1);

A(any(A,2)==0,:)=[];
b(any(b,2)==0,:)=[];


% %% 使用输入方程组中第n个公式进行降次
% anchor_coord = anchor_matrix(:,1:2);        % 取输入参数矩阵的前两列为锚节点的坐标矩阵
% anchor2unknown_d = anchor_matrix(:,3);      % 取输入参数矩阵的第三列作为锚节点和位置节点间距离的向量
% anchor_n = length(anchor_coord');
% 
% A = 2 * (anchor_coord(1:anchor_n-1,:) - repmat(anchor_coord(anchor_n,:),anchor_n-1,1));     % 求降次后的超定矩阵系数A,注意这里的系数和word中推导的系数差了一个负号
% anchor_coord_square_sum = transpose(sum(transpose(anchor_coord.^2)));       % 求锚节点坐标的平方和
% dist_square = anchor2unknown_d.^2;      % 求距离d的平方
% b = anchor_coord_square_sum(1:anchor_n-1)- anchor_coord_square_sum(anchor_n) - dist_square(1:anchor_n-1) + dist_square(anchor_n);


%% default run lls in overdetermined equations
UKnode_coord = A\b;

end

