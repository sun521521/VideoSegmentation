function [sNewSource, sNewDestination, sNewWeights] = computeV( superpixels, centres, colours, labels)

   
    [ sSource, sDestination ] = ...  %  sSource， sDestination：都是列向量
        getSpatialConnections( superpixels, labels );
   
   

    sSqrColourDistance = sum( ( colours( sSource + 1, : ) - ... % c语言中，数组下标从0开始，所以要加1
        colours( sDestination + 1, : ) ) .^ 2, 2 ) ;
    sCentreDistance = sqrt( sum( ( centres( sSource + 1, : ) - ...
        centres( sDestination + 1, : ) ) .^ 2, 2 ) );
    
    % t的相似性（交集/warp（上一个块）且正数坐标），上面已经求出

    sBeta = 1.5 / mean( sSqrColourDistance ./ sCentreDistance );
 
    sWeights = exp( -sBeta * sSqrColourDistance ) ./ sCentreDistance;

    sNewSource =  sSource;
    sNewDestination = sDestination;
    sNewWeights = sWeights;