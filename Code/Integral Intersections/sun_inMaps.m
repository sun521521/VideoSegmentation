function inMaps = sun_inMaps(inRatios, superpixels, inMaps)
% Ã»ÓÃµ½

frames = length(inMaps);

threshold = 0.4;
for frame = 1:frames
    needToFill = find(inRatios{frame} > threshold);
    
    for i = 1:length(needToFill)
        inMaps{frame}(superpixels{frame} == needToFill(i)) = true;
    end
end