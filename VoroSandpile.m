function [avalanche_output, pile, avalanche_store] = VoroSandpile(pile_width, no_of_voronoi, no_of_grains, ...
    boundary_gap, draw_speed)

% main function for simulating the sand pile model, where we construct the
% initial configuration, size of the system, and start to add sand grains
% to the system
% author: Teng Man, manteng0520@outlook.com
% Reference: https://github.com/flrs/visual_sandpile


%------------- BEGIN CODE --------------
%% check inputs
assert(nargin >= 4, 'The function %s needs at least 4 inputs.', mfilename);

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
pile = zeros(no_of_voronoi,4);
pile_store = zeros([no_of_voronoi, 4, 1]);
pile_store_add = 0;
avalanche_plt = 0;  
avalanche_store = [];

xpos = pile_width.*rand([1 no_of_voronoi]);
ypos = pile_width.*rand([1 no_of_voronoi]);

h = voronoi(xpos,ypos);
% get the position vector of all the particles
Pos = [xpos;ypos];
Pos = Pos';
% extract the data of the vertex and the edge
[Vert Edge] = voronoin(Pos);
% get the neighbor matrix
vn = voronoi_neighbors(Pos);
particles = SandData.empty(no_of_voronoi,0);
EdgeParticle = [];
CtEdge = 1;
for i = 1:no_of_voronoi
    particles(i).Pos = Pos(i,:);
    particles(i).ID = i;
    count = 0;
    for j = 1:no_of_voronoi
        if j ~= i && vn(i,j)==1
            count = count+1;
            particles(i).NbrID(count)=j;
            particles(i).NbrNum = count;
        end
    end
    
%     particles(i).Value = randi([1, max(1,ceil(0.5*particles(i).NbrNum))]);
    particles(i).Value = 0;
    pile(i,1) = xpos(i);
    pile(i,2) = ypos(i);
    pile(i,3) = particles(i).Value;
    pile(i,4) = particles(i).NbrNum;
    
    if pile(i,1)<=boundary_gap || pile(i,1)>=pile_width-boundary_gap || ...
            pile(i,2)<=boundary_gap || pile(i,2)>=pile_width-boundary_gap
        EdgeParticle(CtEdge) = i;
        CtEdge = CtEdge + 1;
    end
end

avalanche_output = [];

% initialize plots
[pointer_patch, pile_img, avalanche_ct_plot, avalanche_desc_text] = ...
    VoroSetupPlots(pile_width, no_of_voronoi, draw_speed, pile, Vert, Edge);

%% run model
% generate pile
for ct = 1:no_of_grains
    % add grain to pile
    fprintf('Adding grain %.0f of %.0f...\n', ct, no_of_grains);
    add2id = randi([1, no_of_voronoi]);
    
    pile(add2id,3) = pile(add2id, 3)+1;
    particles(add2id).Value = particles(add2id).Value + 1;
    pile_store = pile;
    pile_store_add = add2id;
    avalanche_size = 0;
    
    % resolve peak
    peaks = scanPileForPeaks(pile, no_of_voronoi);
    intermediate_piles = [];
    while numel(peaks) ~= 0
        [pile, particles, intermediate_piles] = resolveVoroPeaks(pile, particles, peaks, no_of_voronoi);
        if ~isempty(intermediate_piles)
            if draw_speed
                pile_store = cat(3, pile_store, intermediate_piles);
            end
            avalanche_size = avalanche_size + size(intermediate_piles, 3);
        end
        peaks = scanPileForPeaks(pile, no_of_voronoi);
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
    
    % erase all the sand grains in the sinking region
    if mod(ct,500)==0
        for iEdge = 1:length(EdgeParticle)
            pile(EdgeParticle(iEdge), 3) = 0;
        end
    end
    % call plot function
%     plotVoroPile(pile_store, pile_store_add, pile_img, pointer_patch,...
%         ct, avalanche_plt, avalanche_ct_plot, avalanche_desc_text,...
%         draw_speed, pile_width, Vert, Edge);   
    
    
end


