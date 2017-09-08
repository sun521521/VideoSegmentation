function [totalInSegments, totalExSegments] = sun_getTotalInExsegments(locationUnaries, superpixels, edgePoints, lamdaIn, lamdaEx)

totalInSegments = [];  totalExSegments = [];

for i = 1:length( edgePoints )
    [inSegments exSegments] = sun_getInExSegments(locationUnaries, superpixels{i}, edgePoints{i}, lamdaIn, lamdaEx);
    
    totalInSegments = [totalInSegments inSegments];
    totalExSegments = [totalExSegments exSegments];
end