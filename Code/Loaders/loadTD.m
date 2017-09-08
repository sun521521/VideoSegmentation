function [sNewSource,sNewDestination,tdScore] = loadTD( options )

tic; fprintf( '\t\t\t load sun_TD...\t\t');

file = fullfile( options.outfolder, 'processing', sprintf( 'sun_TD.mat' ) );
fileV = fullfile( options.outfolder, 'processing', sprintf( 'sun_V.mat' ) );
 sun_V  = load(fileV);

if exist( file, 'file' )
    
    sun_TD  = load(file);   
    if isfield( sun_TD, 'thetaScore' )
        sNewSource = sun_TD.sNewSource;
       sNewDestination = sun_TD.sNewDestination;
       tdScore = sun_TD.thetaScore;
    else
        warning( '%s: no known field found\n', file );
        sNewSource = sun_V.sNewSource; sNewDestination = sun_V.sNewDestination; tdScore = [];
    end
else
%     warning( '%s not found\n', file );
   sNewSource = sun_V.sNewSource; sNewDestination = sun_V.sNewDestination; tdScore = [];
end
toc;