% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% this matlab code is for simulating the sand pile model presented in Bak
% et al, PRL, 1987 on a 2D Voronoi space
% Author: Teng Man, manteng0520@outlook.com
% November 2021
% Note: lots of the code were modified from
%       https://github.com/flrs/visual_sandpile
% 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

% clear everything
close all; clear all;
clc

% initialization
pile_width = 50;            % width of the Voronoi sand pile
boundary_gap = 1;           % gap of the sinking region
voronoiNum = pile_width^2;  % number of voronoi positions in the space
sandNum = 30000;            % number of sand grains we want to add to the space
realNum = 1;                % number of realizations, 1 is OK for simulation
lakeLevel = 4;              % the level below which is considered under water

avalanche = [];
avalanche_store = [];
output = [];
pile = [];
VoroArea = [];

% main calculation
for i = 1:realNum
    avalanche = [];
    [output, pile, avalanche]=VoroSandpile(pile_width, voronoiNum, sandNum,...
        boundary_gap, 0.1);
    avalanche_store = [avalanche_store, avalanche];
end


%% plot the histogram of number of neighbors
figure
hn = histogram(pile(:,4),'BinWidth',1)
histoNbr = hn.BinEdges(1:end-1);
ProbNbr = hn.Values;

figure
plot(histoNbr, ProbNbr, 'd','MarkerSize',8, 'MarkerEdgeColor','k','MarkerFaceColor','b')
set(gca,'XScale','log')
set(gca,'YScale','log')


%% plot the histogram with fitting
figure
h = histogram(avalanche_store,'BinWidth',1);
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([1 100])

histoEdge = h.BinEdges;
histoData = h.Values;
xfit = histoEdge(1:end-1);
yfit = histoData;

[fitresult, gof, xData, yData] = createPowerFit(xfit, yfit);

avalanchHisto = figure('position', [200 200 500 500])
% plot(histoEdge(1:end-1), histoData, 'o','MarkerEdgeColor','k',...
%     'MarkerFaceColor','g','MarkerSize',8)
% hold on
plt = plot(fitresult,'--r',xData,yData,'ok');
set(gca,'XScale','log')
set(gca,'YScale','log')
set(gca,'FontSize',14)
plt(1).MarkerSize = 10;
plt(1).MarkerFaceColor = 'g';
plt(2).LineWidth = 1.5;
ylim([1 2000])
xlabel('Avalanche Size')
ylabel('No. of observed avalanches')
% set(gca,'FontName','Times New Roman')
set(gca,'FontName','Nimbus Roman') % for Ubuntu system
exportgraphics(avalanchHisto,'AvalancheHisto.png','Resolution',1500)


%% plot final landscape

finalConfig = figure('position', [200 200 500 500]);
pile_img = voronoi(pile(:,1), pile(:,2));
hold on
MaxNbr = max(pile(:,4));
[Vert Edge] = voronoin(pile(:,1:2));
for ik = 1:length(Edge)
    fill(Vert(Edge{ik},1), Vert(Edge{ik},2), ...
        [1-pile(ik,3)/MaxNbr, 1-pile(ik,3)/MaxNbr, 1-pile(ik,3)/MaxNbr]);
    hold on
end
    
set(gcf, 'Units', 'normal')
set(gca, 'Position', [0 0 1 1])

% set image-specific properties
colormap(gray(MaxNbr));
xlim([0 pile_width]);
ylim([0 pile_width]);
set(gca, 'xtick', [],'ytick', []);
exportgraphics(finalConfig,'finalConfig.png','Resolution',1500)


%% plot the lake/land binary plot

LakeFig = figure('position', [200 200 1000 1000]);
% pile_img = voronoi(pile(:,1), pile(:,2));
% hold on
fill([0, pile_width, pile_width, 0],[0, 0, pile_width, pile_width],[0,0,0])
hold on
for ik = 1:length(Edge)
    if pile(ik,3)<lakeLevel && pile(ik,1)>=boundary_gap && pile(ik,1)<=pile_width-boundary_gap ...
            && pile(ik,2)>=boundary_gap && pile(ik,2)<=pile_width-boundary_gap
        voroColor = 1;
        fill(Vert(Edge{ik},1), Vert(Edge{ik},2), ...
            [voroColor, voroColor, voroColor],'EdgeColor','w');
        hold on
    else
        voroColor = 0;
        fill(Vert(Edge{ik},1), Vert(Edge{ik},2), ...
            [voroColor, voroColor, voroColor]);
        hold on
    end
    
end 
set(gcf, 'Units', 'normal')
set(gca, 'Position', [0 0 1 1])
% set image-specific properties
colormap(gray(MaxNbr));
xlim([0 pile_width]);
ylim([0 pile_width]);
set(gca, 'xtick', [],'ytick', []);
exportgraphics(LakeFig,'LakeFig.png','Resolution',1500)

%% plot the histogram of voronoi areas
VoroArea = [];
for ia = 1:length(Edge)
    vert1 = Vert(Edge{ia},1);
    vert2 = Vert(Edge{ia},2);
    if pile(ia,1)>=boundary_gap && pile(ia,1)<=pile_width-boundary_gap ...
            && pile(ia,2)>=boundary_gap && pile(ia,2)<=pile_width-boundary_gap
        VoroArea = [VoroArea, polyarea(vert1, vert2)];
    end
end


MeanArea = mean(VoroArea(~isnan(VoroArea)));
MedianArea = median(VoroArea(~isnan(VoroArea)));
StdArea = std(VoroArea(~isnan(VoroArea)));

figure
AvHisto = histogram(VoroArea,'BinWidth',0.1,'normalization','pdf')
AvProb = AvHisto.Values;
AvValues = 0.5.*(AvHisto.BinEdges(1:end-1) + AvHisto.BinEdges(2:end)) ;

PeakArea = AvValues(AvProb == max(AvProb));

voroareaX = AvValues./MeanArea;
probTheoretical = (343/15).*sqrt(7/2/pi).*voroareaX.^2.5.*exp(-7.*voroareaX./2);

voroFig = figure('position', [200 200 1000 500]);
subplot(1,2,1)
plot(voroareaX, AvProb, 'ok','MarkerSize',8)
hold on
plot(voroareaX, probTheoretical, '--')
xlabel('$V_{s}/\langle V_{s}\rangle$','interpreter','latex')
ylabel('Probability')
xlim([0 6])
ylim([0 1])
legend('Data','Ferenc & Neda 2007','FontSize',12,'location','northeast')
set(gca,'FontName','Nimbus Roman')
set(gca, 'FontSize',14)


subplot(1,2,2)
plot(voroareaX, AvProb, 'ok','MarkerSize',8)
hold on
plot(voroareaX, probTheoretical, '--')
set(gca,'XScale','log')
set(gca,'YScale','log')
ylim([0.001 1])
xlabel('$V_{s}/\langle V_{s}\rangle$','interpreter','latex')
ylabel('Probability')
legend('Data','Ferenc & Neda 2007','FontSize',12,'location','southwest')
set(gca,'FontName','Nimbus Roman')
set(gca, 'FontSize',14)

exportgraphics(voroFig,'voroFig.png','Resolution',900)

%% statistics of the lake
LakeArea = [];
LakeArea = calc_lakeareas(pile_width);

figure('position', [200 200 500 500]);
lakeHisto = histogram(LakeArea./MeanArea, 'BinWidth',1,'normalization','pdf')
set(gca,'XScale','log')
set(gca,'YScale','log')

lakeFig = figure('position', [200 200 500 500]);
lakeSizeProb = lakeHisto.Values;
lakeSize = 0.5.*(lakeHisto.BinEdges(1:end-1) + lakeHisto.BinEdges(2:end));
plot(lakeSize, lakeSizeProb, 'ok','MarkerSize',10, 'MarkerFaceColor','c')
xlabel('$A_{l}/\langle V_{s}\rangle$','interpreter','latex')
ylabel('Probability')
set(gca,'XScale','log')
set(gca,'YScale','log')
% set(gca,'FontName','Times New Roman')
set(gca,'FontName','Nimbus Roman') % for Ubuntu system
set(gca,'FontSize',14)

exportgraphics(lakeFig,'LakeFig.png','Resolution',900)
