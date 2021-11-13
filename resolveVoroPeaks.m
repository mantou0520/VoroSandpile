function [pile, particles, intermediate_piles] = resolveVoroPeaks(pile, particles, peak_pos, pile_width)
%resolveVoroPeaks - Resolve all peaks in a pile
%
% Syntax:  [pile, particles, intermediate_piles] = resolvePeaks(pile, particles, peak_pos, pile_width)
%
% Inputs:
%    pile - information of voronoi elements
%    particles - objects which have all the neighbor info of voronoi
%                   elements
%    peak_pos - Vector containing positions of all peaks
%    pile_width - Here, pile_width means the number of voronoi elements
%
% Outputs:
%    pile - information of voronoi elements
%    particles - objects which have all the neighbor info of voronoi
%                   elements
%    intermediate_piles - Matrix of shape (pile width, pile width, no. of
%    intermediate time steps), with integer values from 0 to 4, containing 
%    all intermediate steps taken in resolving the peaks
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: 
%
% Author: Teng Man
% Website: 
% November 2021;
% Reference: https://github.com/flrs/visual_sandpile

%------------- BEGIN CODE --------------
%% initialize

prealloc_size = round(pile_width^1.3); % preallocate empty array depending
                                       % on pile side length, it is
                                       % expected that no. of piles
                                       % increases exponentially with pile
                                       % side length, exponent 1.3 is
                                       % arbitrary and a tradeoff between
                                       % unneccessarily slow intialization
                                       % and unneccessary overhead when 
                                       % expanding the array later in the
                                       % code
intermediate_piles = zeros(pile_width,4,prealloc_size);
intermediate_pile_ct = 1;

% peak_pattern = [0 1 0;1 -4 1;0 1 0;]; % pattern for resolving peaks, 
%                                       % characteristic of Abelian sandpile
% 
% pile_frame = zeros(pile_width+2); % construct frame around pile to catch
%                                   % falling off the grid
% pile_frame(2:end-1,2:end-1) = pile; % insert pile into frame

%% process peaks
% resolve peaks one by one
for peak = 1:numel(peak_pos)
    % fast ind2sub (see http://tipstrickshowtos.blogspot.com/2011/09/fast-r
    % eplacement-for-ind2sub.html, checked on 2017-01-26)
%     peakY = rem(peak_pos(peak)-1, pile_width)+1;
%     peakX = (peak_pos(peak)-peakY)/pile_width + 1;
    
    % resolve peaks
%     particles(peak_pos(peak)).Value = particles(peak_pos(peak)).Value - ...
%         particles(peak_pos(peak)).NbrNum;
    pile(peak_pos(peak),3) = pile(peak_pos(peak),3)-pile(peak_pos(peak),4);
    nbrID = particles(peak_pos(peak)).NbrID;
    for ik = 1:length(nbrID)
%         particles(nbrID(ik)).Value = particles(nbrID(ik)).Value + 1;
        pile(nbrID(ik),3) = pile(nbrID(ik),3)+1;
    end
%     pile_frame(peakY:peakY+2, peakX:peakX+2) = ...
%         pile_frame(peakY:peakY+2, peakX:peakX+2)+peak_pattern;
    
    % extract new pile from frame
%     pile = pile_frame(2:end-1, 2:end-1);
    
    % expand intermediate pile array when it has reached its size limit
    if intermediate_pile_ct>size(intermediate_piles, 3)
        intermediate_piles = ...
            cat(3, intermediate_piles, ...
            zeros(pile_width, 4, prealloc_size));
    end
    
    % append new pile to intermediate pile array
    intermediate_piles(:, :, intermediate_pile_ct) = pile;
    
    intermediate_pile_ct = intermediate_pile_ct+1;
end

if intermediate_pile_ct>1
    % eliminate unused, preallocated entries from intermediate pile array
    intermediate_piles = intermediate_piles(:, :, 1:intermediate_pile_ct-1);
else
    % no piles resolved
    intermediate_piles = [];
end

end
