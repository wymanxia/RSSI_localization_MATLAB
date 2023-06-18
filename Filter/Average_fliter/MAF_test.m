% this file weyman added to test MAF algorithm
% to see the world as it is and to love it 

clc;
clear all;
close all;

theorydata = 50 * ones(1,50);
testdata = theorydata + 4 * randn(1,50);
[data_output,remained] = MovingAverageFunc(testdata,3);

