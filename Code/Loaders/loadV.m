function [sNewSource, sNewDestination, sNewWeights] = loadV( options )

tic; fprintf( '\t\t\t load sun_V...\t\t');

file = fullfile( options.outfolder, 'processing', sprintf( 'sun_V.mat') );

if exist( file, 'file' )
    
    sun_V  = load(file);
    if isfield( sun_V, 'sNewSource' )
        sNewSource = sun_V.sNewSource;
        sNewDestination = sun_V.sNewDestination;
        sNewWeights = sun_V.sNewWeights;
    else
        warning( '%s: no known field found\n', file );
        sNewSource = []; sNewDestination = []; sNewWeights = [];
    end
else
%     warning( '%s not found\n', file );
    sNewSource = []; sNewDestination = []; sNewWeights = [];
end
toc;