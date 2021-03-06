function [fitresult, gof,xData,yData] = createPowerFit(xfit, yfit)
%CREATEFIT(XFIT,YFIT)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : xfit
%      Y Output: yfit
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 11-Nov-2021 12:36:42

% author: Teng Man, manteng@westlake.edu.cn


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( xfit, yfit );

% Set up fittype and options.
ft = fittype( 'power1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = [1884.90564195574 -1.09358457982577];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% % Plot fit with data.
% figure( 'Name', 'untitled fit 1' );
% h = plot( fitresult, xData, yData );
% legend( h, 'yfit vs. xfit', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% % Label axes
% xlabel( 'xfit', 'Interpreter', 'none' );
% ylabel( 'yfit', 'Interpreter', 'none' );
% set(gca, 'XScale','log')
% set(gca, 'YScale','log')
% grid on


