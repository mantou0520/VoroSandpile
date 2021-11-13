function peak_pos = scanPileForPeaks(pile, no_of_voronoi)
%scanPileForPeaks - Find all peaks in a sandpile
%
% Syntax:  peak_pos = scanPileForPeaks(pile)
%
% Inputs:
%    pile - information of the voronoi sand pile
%    no_of_voronoi - number of voronoi elements
%
% Outputs:
%    peak_pos - Vector containing positions of all peaks
%
% Example:
%    peak_pos = scanPileForPeaks([0 1 3; 4 1 2; 2 1 0], 9);
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: simulateSandpile
%
% Author: Teng Man
% Website: 
% November 2021; 

%------------- BEGIN CODE --------------
peak_pos = [];
for ik = 1:no_of_voronoi
    if pile(ik,3)>=pile(ik,4)+1
        peak_pos = [peak_pos, ik];
    end
end
%------------- END CODE --------------

