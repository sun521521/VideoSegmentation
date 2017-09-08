function [potentials, vNumbers] = sun_computeTernaryPotentials( options,  params, superpixels, flow, colours, centres, labels ,bounds, nodeFrameId,  potentialMatrix,data)


% 疑似前景区域(只对单节点势能约束)
 potentialMatrix.appearance = -log(potentialMatrix.appearance);
 potentialMatrix.location= -log(potentialMatrix.location);
 potentialMatrix.LA = -log(potentialMatrix.LA);
 appearance = mapBelief( potentialMatrix.appearance ); location = mapBelief( potentialMatrix.location );  LA = mapBelief(  potentialMatrix.LA  );
 
  foregroundMasks = appearance./maxmax(appearance)>=0  |  location./maxmax(location)>=0  |  LA./maxmax( LA )>=0; 

  
  
  [sNewSource, sNewDestination, sNewWeights] = loadV( options);
  if( isempty( sNewWeights ) )
      if( options.vocal ), tic; fprintf( '\t\tComputing spatial potentials...\t' ); end
      [sNewSource, sNewDestination, sNewWeights] = sun_computeV(options, superpixels, colours, centres, labels, foregroundMasks );
%       [sNewSource, sNewDestination, sNewWeights] = computeV( superpixels, centres, colours, labels);
      if( options.vocal ), toc; end
  end

  
  [tNewSource, tNewDestination, tNewWeights] = loadW( options );
  if( isempty( tNewWeights ) )
      if( options.vocal ), tic; fprintf( '\t\tComputing temporal potentials...\t' ); end
      [tNewSource, tNewDestination, tNewWeights] = sun_computeW(options, superpixels, flow, colours, labels, foregroundMasks );
%       [tNewSource, tNewDestination, tNewWeights] = computeW( superpixels, flow, colours, labels);
      if( options.vocal ), toc; end
  end

  
  [sNewSource,sNewDestination,tdScore] = loadTD( options );
  if( isempty( tdScore) )
      if( options.vocal ), tic; fprintf( '\t\tComputing temporalDist potentials...\t' ); end
      % [sNewSource,sNewDestination, tdScore] = sun_computeTemporalDist1(sNewSource, sNewDestination, superpixels, bounds, sunflow, foregroundMasks );
      [sNewSource,sNewDestination,tdScore]  = sun_computeTemporalDist2(options, sNewSource, sNewDestination, superpixels, bounds, colours,flow);
      % tdScorce = 0;
      if( options.vocal ), toc; end
  end

       potentials.source = [ sNewSource;tNewSource ];
    potentials.destination = [ sNewDestination; tNewDestination ];
    potentials.value = [ params.spatialWeight * sNewWeights + params.tdWeight *(tdScore) ; ...
        params.temporalWeight * tNewWeights ];
vNumbers = length( sNewSource );