function LakeArea = calc_lakeareas(pile_width)

% calc_lakeareas - identify and calculate the area of all the lakes in the
% space
% 
% input:
%       pile_width - the width of the voronoi sandpile
%       
% output:
%       LakeArea - the areas of all the lakes identified
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

%------------- BEGIN CODE --------------

im = imread('LakeFig.png');
[row col page] = size(im);
length_per_pixel = pile_width/row;
area_per_pixel = length_per_pixel^2;

bw = imbinarize(im);
bw = im2uint8(bw);

bww = bwareaopen(bw, 100);
bww = im2uint8(bww);

cc = bwconncomp(bww,26);
labeled = labelmatrix(cc);
labeled = im2uint8(labeled);
whos labeled

objectsdata = regionprops(cc, 'basic');

LakeArea = [];

for i = 1:length(objectsdata)
    LakeArea(i) = objectsdata(i).Area * area_per_pixel;
end

%------------- END CODE --------------