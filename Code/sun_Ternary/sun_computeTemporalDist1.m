function [sNewSource,sNewDestination, result] = sun_computeTemporalDist1(sNewSource, sNewDestination, superpixels, bounds, sunflow, foregroundMasks )

flow = sunflow; 
sNewSource = sNewSource+1; sNewDestination  = sNewDestination + 1;
frames = length(flow);   [height, width, anyvalues] = size(flow{1});

theta = cell(frames, 1);
for frame = 1:frames
    theta{frame} = atan2(double(flow{frame}(:, :, 2)), double(flow{frame}(:, :, 1)) );
        theta{frame}( flow{frame}( :, :, 1 ) == 0 & flow{frame}( :, :, 2 ) == 0 ) = 0;

end



change = [];  changeTheta = [];
for frame = 1:frames
    focusIndex = sNewSource >= bounds(frame) & sNewSource <= bounds(frame+1) -1;
    focusSource = sNewSource(focusIndex); focusDestination = sNewDestination(focusIndex);
    
    u = flow{frame}(:, :, 2);  v = flow{frame}(:, :, 1); thetaFrame = theta{frame};
    superFrame = superpixels{frame};    
    for i = 1:length(focusSource)
        [x1, y1] = find( superFrame == focusSource(i)); meanX1 = mean(x1); meanY1 = mean(y1); center1 = [meanX1 meanY1];
        [x2, y2] = find( superFrame == focusDestination(i)); meanX2 = mean(x2); meanY2 = mean(y2); center2 = [meanX2 meanY2];
        foreDist = ( sum((center1 - center2).^2) );
        
        indexFlow1 = sub2ind([height, width], x1, y1);  indexFlow2 = sub2ind([height, width], x2, y2);
        nextX1 = meanX1 + mean(v(indexFlow1));   nextY1 = meanY1 + mean(u(indexFlow1)); 
        nextX2 = meanX2 + mean(v(indexFlow2));   nextY2 = meanY2 + mean(u(indexFlow2)); 
         
        tempChange = abs( mean(thetaFrame(indexFlow1)) - mean(thetaFrame(indexFlow2)) );
         changeTheta = [changeTheta; tempChange];
        
%          index1 = (nextX1 >=1 & nextX1 <= height & nextY1 >=1 & nextY1 <= width);
%         nextX1 = nextX1(index1);
%         nextY1 = nextY1(index1); 
% 
%          index2 = (nextX2 >=1 & nextX2 <= height & nextY2 >=1 & nextY2 <= width);
%         nextY2 = nextY2( index2 );
%          nextX2 = nextX2( index2 );
         
         if (nextX1 < 1 || nextX1 > height || nextY1 < 1 || nextY1 > width) || (nextX2 < 1 || nextX2 > height || nextY2 < 1 || nextY2 > width)
              change = [change; nan];
              continue
         end
        
        
         centerBack1 = [nextX1 nextY1];  centerBack2 = [nextX2 nextY2];
        backDist = ( sum((centerBack1 - centerBack2).^2) );
        change = [change; double(abs(foreDist - backDist) ) ];
    end
end

%  tdColourDistance = sum( ( colours( sNewSource, : ) - ...
%         colours( sNewDestination, : ) ) .^ 2, 2 ) ;

 change = change.^0.5;  changeTheta  = changeTheta.^0.5;

betaDis = 0.3/mean(  change( logical(~isnan(change) .* single( foregroundMasks(sNewSource) | foregroundMasks(sNewDestination) ) )));
betaTheta = 7 * betaDis;


tdScore = single(exp( -betaDis.* change .* single(foregroundMasks(sNewSource) | foregroundMasks(sNewDestination) )));
tdScore( isnan(change) ) = 0.1 ;

thetaScore = single(exp( -betaTheta.* changeTheta .* single(foregroundMasks(sNewSource) | foregroundMasks(sNewDestination) )));

result = zeros(length(tdScore), 1);  
beta = 0.6;
result(tdScore >beta) = tdScore(tdScore >beta);  result(tdScore <=beta) = thetaScore(tdScore <=beta) .* tdScore(tdScore <=beta);


sNewDestination = uint32(sNewDestination) - 1;  % c语言下标从0开始
sNewSource =  uint32(sNewSource)-1;
        