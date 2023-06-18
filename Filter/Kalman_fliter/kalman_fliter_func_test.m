% a test to check kalman function
% 20220325 add read serialport data from ZFC and process it

clear;
clc;
close all;

theorydata = -90*ones(1,50);
testdata = theorydata + 4*randn(1,50);
l_testdata = length(testdata);
[output,outputerror] = kalman_fliter_func(testdata,l_testdata,0.01,0.01);



