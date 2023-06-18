%**************  This is a test file created by weyman xia   *************%

% create serialport object to read data from coordinator, alternate X with
% actual number of PC COM
s=serialport("COMX",9600);

% input the RSSI data from coordinator
% need to judge different Anchor Point RSSI data - HOW ???
data1=read("COMX",60,"int8");
data2=;
data3=;

% run kailman fliter and other fliter (if needed)
% use function write kalman fliter

% run math funtion fit and choosing strategy
% shadow model or other model

% run location algorithm

% plot result and calculate the deviation

% additional: how to create GUI









