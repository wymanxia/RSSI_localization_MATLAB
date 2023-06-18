% this file weyman added to test GF algorithm
% to see the world as it is and to love it 

clc;
clear all;
close all;

theorydata = -90*ones(1,50);
testdata = theorydata + 4*randn(1,50);
[data_output,remained] = GaussianFunc(testdata,2,3,2);

