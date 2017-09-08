function [inSegments exSegments] = sun_getInExSegments(  spixelRatio, superpixels, edgePoints, lamdaIn, lamdaEx)


%  lamdaIn = 0;
%  lamdaEx = 0;
if ~isfloat( superpixels) ||  ~isfloat( edgePoints)
    superpixels = double(superpixels);  edgePoints = double(edgePoints);
end

% 得到与边相交的超像素块
interSecs = unique(superpixels .* edgePoints);   interSecs  =  interSecs(interSecs ~= 0);

inSegments = []; exSegments = [];
for i  = 1:length(interSecs)
    if spixelRatio(interSecs(i)) > 0.5*lamdaIn && spixelRatio(interSecs(i)) < 0.7*lamdaIn
        inSegments = [inSegments interSecs(i)];
    elseif spixelRatio(interSecs(i)) > 0.2*lamdaEx && spixelRatio(interSecs(i)) < 0.5*lamdaEx
        exSegments = [exSegments interSecs(i)];
    end
end