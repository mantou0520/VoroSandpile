close all; clear all;
clc

voronoiNum = 1000;
sandNum = 1500;
realNum = 1;

avalanche = [];
avalanche_store = [];
output = [];
pile = [];

for i = 1:realNum
    avalanche = [];
    [output, pile, avalanche]=VoroSandpile(voronoiNum, sandNum, 0.1);
    avalanche_store = [avalanche_store, avalanche];
end

figure
h = histogram(avalanche_store,'BinWidth',1)
set(gca,'XScale','log')
set(gca,'YScale','log')
xlim([1 100])

histoEdge = h.BinEdges;
histoData = h.Values;
figure
plot(0.5*(histoEdge(1:end-1)+histoEdge(2:end)), histoData, 'o','MarkerEdgeColor','k',...
    'MarkerFaceColor','g','MarkerSize',8)
set(gca,'XScale','log')
set(gca,'YScale','log')
xlabel('Avalanche Size')
ylabel('No. of observed avalanches')
set(gca,'FontName','Times New Roman')
% set(gca,'FontName','Nimbus Roman') % for Ubuntu system
