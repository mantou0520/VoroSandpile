function [avalanche_output, pile, avalanche_store] = VoroSandpile(pile_width, no_of_grains, ...
    draw_speed)



%------------- BEGIN CODE --------------
%% check inputs
assert(nargin >= 3, 'The function %s needs at least 3 inputs.', mfilename);

check_vars = {pile_width, 'pile_width';
    no_of_grains, 'no_of_grains';
    draw_speed, 'draw_speed'};

for ct = 1:size(check_vars,1)
    assert(isfloat(check_vars{ct,1}), ['The input variable "%s" needs to'...
    ' be a floating point number.'], check_vars{ct,2});
    assert(numel(check_vars{ct,1})==1, ['The input variable "%s" needs to'...
        ' be a scalar.'], check_vars{ct,2});
end

for ct = 1:2
    assert(check_vars{ct,1}>0, ['The value of the input variable "%s" '...
        'needs to be greater than zero.'], check_vars{ct,2});
end

%% initilization
pile = zeros(pile_width,4);
pile_store = zeros([pile_width, 4, 1]);
pile_store_add = 0;
avalanche_plt = 0;  
avalanche_store = [];

xpos = pile_width.*rand([1 pile_width]);
ypos = pile_width.*rand([1 pile_width]);

h = voronoi(xpos,ypos);
% get the position vector of all the particles
Pos = [xpos;ypos];
Pos = Pos';
% extract the data of the vertex and the edge
[Vert Edge] = voronoin(Pos);
% get the neighbor matrix
vn = voronoi_neighbors(Pos);
particles = SandData.empty(pile_width,0);
for i = 1:pile_width
    particles(i).Pos = Pos(i,:);
    particles(i).ID = i;
    count = 0;
    for j = 1:pile_width
        if j ~= i && vn(i,j)==1
            count = count+1;
            particles(i).NbrID(count)=j;
            particles(i).NbrNum = count;
        end
    end
    particles(i).Value = randi([1, max(1,ceil(0.8*particles(i).NbrNum))]);
    pile(i,1) = xpos(i);
    pile(i,2) = ypos(i);
    pile(i,3) = particles(i).Value;
    pile(i,4) = particles(i).NbrNum;
end

avalanche_output = [];

% initialize plots
[pointer_patch, pile_img, avalanche_ct_plot, avalanche_desc_text] = ...
    VoroSetupPlots(pile_width, draw_speed, pile, Vert, Edge);

%% run model
% generate pile
for ct = 1:no_of_grains
    % add grain to pile
    fprintf('Adding grain %.0f of %.0f...\n', ct, no_of_grains);
    add2id = randi([1, pile_width]);
    
    pile(add2id,3) = pile(add2id, 3)+1;
    particles(add2id).Value = particles(add2id).Value + 1;
    pile_store = pile;
    pile_store_add = add2id;
    avalanche_size = 0;
    
    % resolve peak
    peaks = scanPileForPeaks(pile, pile_width);
    intermediate_piles = [];
    while numel(peaks) ~= 0
        [pile, particles, intermediate_piles] = resolveVoroPeaks(pile, particles, peaks, pile_width);
        if ~isempty(intermediate_piles)
            if draw_speed
                pile_store = cat(3, pile_store, intermediate_piles);
            end
            avalanche_size = avalanche_size + size(intermediate_piles, 3);
        end
        peaks = scanPileForPeaks(pile, pile_width);
    end
    
    % update avalanche counter
    if avalanche_size > 0
        if numel(avalanche_plt)>=avalanche_size
            avalanche_plt(avalanche_size) = ...
                avalanche_plt(avalanche_size)+1;
        else
            avalanche_plt(avalanche_size) = 1;
        end
        fprintf(['Captured avalanche with duration of %.0f time ',...
            'steps.\n'], avalanche_size);
        avalanche_store = [avalanche_store, avalanche_size];
    end
    
    % call plot function
%     plotVoroPile(pile_store, pile_store_add, pile_img, pointer_patch,...
%         ct, avalanche_plt, avalanche_ct_plot, avalanche_desc_text,...
%         draw_speed, pile_width, Vert, Edge);   
    
    
end

%% final plot
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


