function [tNewSource, tNewDestination, tNewWeights] = computeW( superpixels, flow, colours, labels)

   
    [ tSource, tDestination, tConnections ] = ...  %  tConnections: 比率， t的相似性（交集/warp（上一个块）且正数坐标）
        getTemporalConnections( flow, superpixels, labels );

   
    
    % t的相似性（交集/warp（上一个块）且正数坐标），上面已经求出
    tSqrColourDistance = sum( ( colours( tSource + 1, : ) - ...
        colours( tDestination + 1, : ) ) .^ 2, 2 ) ;

    tBeta = 1.5 / mean( tSqrColourDistance .* tConnections );

    tWeights = tConnections .* exp( -tBeta * tSqrColourDistance );
    
    tNewSource =  tSource;
    tNewDestination = tDestination;
    tNewWeights = tWeights;