function RSSI()
% 未知节点利用邻居锚节点进行定位，没有邻居锚节点的未知节点无法定位
% 根据接收信号强度转化为距离。规则传播模型下得到的距离跟实际距离没有误差
% 不规则通信模型下，规则传播模型下得到的距离跟实际距离存在误差
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    load '../Deploy Nodes/coordinates.mat';     % 包含了未知节点和锚节点的部署坐标
    load '../Topology Of WSN/neighbor.mat';     % 邻居表中包含了通过模型计算出的RSSI
    directory=cd;
    cd '../Topology Of WSN/Transmission Model/';    
    cd(model);
    unknown_node_index=all_nodes.anchors_n+1:all_nodes.nodes_n;     %总节点数中，除去锚点后的节点即为未知节点的序号，从第一个未知节点开始计算
    for i=unknown_node_index
        neighboring_anchor_index=intersect(find(neighbor_matrix(i,:)==1),find(all_nodes.anc_flag==1));      % 将总节点数进行标号，其中锚节点有anc_flag=1，并且邻居表计算时得出了所有是否是邻居的n*n矩阵
        neighboring_anchor_n=length(neighboring_anchor_index);      
        if neighboring_anchor_n>=3       % 对于某个具体的未知节点，邻居锚节点的数目是否达到要求
            try
                dist=rss2dist(neighbor_rss(neighboring_anchor_index,i),1);
            catch
                dist=rss2dist(neighbor_rss(neighboring_anchor_index,i));
            end
            neighboring_anchor_location=all_nodes.estimated(neighboring_anchor_index,:);        % 选取降次时保留的方程的节点，这里选取保留前9个方程，消去第10个方程降次
            %~~~~~~~~~~~~~~~~~~~~~~~~~三边测量法（最小二乘法）% 疑似暴力求解了定位节点符合的方程组？
            A=2*(neighboring_anchor_location(1:neighboring_anchor_n-1,:)-repmat(neighboring_anchor_location(neighboring_anchor_n,:),neighboring_anchor_n-1,1));     % 直接求降次后的系数矩阵
            neighboring_anchor_location_square=transpose(sum(transpose(neighboring_anchor_location.^2)));
            dist_square=dist.^2;
            b=neighboring_anchor_location_square(1:neighboring_anchor_n-1)-neighboring_anchor_location_square(neighboring_anchor_n)-dist_square(1:neighboring_anchor_n-1)+dist_square(neighboring_anchor_n);
            all_nodes.estimated(i,:)=transpose(A\b);
            all_nodes.anc_flag(i)=2;
        end
    end
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    cd(directory);
    save '../Localization Error/result.mat' all_nodes comm_r;
end