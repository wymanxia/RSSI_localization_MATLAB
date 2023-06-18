function [fitresult, gof] = createFit(distance, rssi, weight)
%CREATEFIT(DISTANCE,RSSI,WEIGHT)
%  Create a fit.
%
%  Data for 'shadow model' fit:
%      X Input : distance
%      Y Output: rssi
%      Weights : weight
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  另请参阅 FIT, CFIT, SFIT.

%  由 MATLAB 于 08-Oct-2022 14:37:24 自动生成


%% Fit: 'shadow model'.
[xData, yData, weights] = prepareCurveData( distance, rssi, weight );

% Set up fittype and options.
ft = fittype( 'a-10*n*log10(x)', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-100 0];
opts.StartPoint = [0.640391599046196 0.957506835434298];
opts.Upper = [5 10];
opts.Weights = weights;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Plot fit with data.
figure( 'Name', 'shadow model' );
h = plot( fitresult, xData, yData );
legend( h, 'rssi vs. distance with weight', 'shadow model', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
xlabel( 'distance', 'Interpreter', 'none' );
ylabel( 'rssi', 'Interpreter', 'none' );
grid on


