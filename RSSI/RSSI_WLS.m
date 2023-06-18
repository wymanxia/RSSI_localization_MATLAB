function UKnode_coord = RSSI_WLS(lls_matrix,weight_vector)
% Brief:   由LLS改进的WLS算法，用于求解定位算法抽象的超定方程组
% Detail:  输入数据的两个矩阵的维度需要额外的注意，这个函数并不会去检查输入
%          矩阵的维度是否满足相应的矩阵运算，不检查输入矩阵参数直接调用可能
%          该函数调用的其他函数或矩阵运算直接报错。区分zenzon在原始文件夹中
%          的相关算法，仅针对实物实现的WSN定位算法。
%          和lls存在额外的改进之处，对于矩阵的降次问题，选择最远锚节点对应
%          方程进行降次消去的方程。
%          不要添加到run.m中去跑
% Arg:     lls_matrix - 等同于lls算法输入矩阵数据，包含锚节点物理坐标和距离
%          weight_matrix - 最小二乘考虑的权重矩阵，谨慎考虑维度及矩阵属性！
% Return:  UKnode_coord - 未知节点的坐标
% Writter: Weyman Xia
% Date:    20230103

[min_d, index] = min(lls_matrix(:,3));          % 获取用于降次的锚节点方程

anchor_d = lls_matrix(:,3);
anchor_coord = lls_matrix(:,1:2);
liner_dim = length(anchor_coord');          % 降次后的超定方程组维度




%% 选取最近锚节点方程降次用于WLS，该模块和下面普通的降次模块只能同时使用一个！
A = 2 * (anchor_coord - repmat(anchor_coord(index,:),liner_dim,1));
anchor_coord_square_sum = transpose(sum(transpose(anchor_coord.^2)));      
dist_square = anchor_d.^2;      
b = anchor_coord_square_sum - ...
    repmat(anchor_coord_square_sum(index), liner_dim, 1 )- ...
    dist_square + ...
    repmat(dist_square(index), liner_dim, 1);

A(any(A,2)==0,:)=[];
b(any(b,2)==0,:)=[];



%% weyman_RSSI_LS算法中继承的降次方式用于处理离线数据，这个模块的代码和上个模块在这个函数中一次只能存在一个
% anchor_coord = lls_matrix(:,1:2);        % 取输入参数矩阵的前两列为锚节点的坐标矩阵
% anchor2unknown_d = lls_matrix(:,3);      % 取输入参数矩阵的第三列作为锚节点和位置节点间距离的向量
% anchor_n = length(anchor_coord');
% 
% A = 2 * (anchor_coord(1:anchor_n-1,:) - repmat(anchor_coord(anchor_n,:),anchor_n-1,1));     % 求降次后的超定矩阵系数A,注意这里的系数和word中推导的系数差了一个负号
% anchor_coord_square_sum = transpose(sum(transpose(anchor_coord.^2)));       % 求锚节点坐标的平方和
% dist_square = anchor2unknown_d.^2;      % 求距离d的平方
% b = anchor_coord_square_sum(1:anchor_n-1)- anchor_coord_square_sum(anchor_n) - dist_square(1:anchor_n-1) + dist_square(anchor_n);




%% 权重矩阵整形及归一化
weight_vector(index) = [];        % 使用最近方程降次时，使用这条代码
% weight_vector(anchor_n) = [];           % 使用第n个方程降次时，使用这条代码
weight_vector = normalize(weight_vector, 'norm', 1);
w = diag(weight_vector);

%% 调用WLS
UKnode_coord = lscov(A,b,w);

end

