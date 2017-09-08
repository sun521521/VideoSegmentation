function [tNewSource, tNewDestination, tNewWeights] = loadW( options )

tic; fprintf( '\t\t\t load sun_W...\t\t');

file = fullfile( options.outfolder, 'processing', sprintf( 'sun_W.mat' ) );

if exist( file, 'file' )
    
    sun_W  = load(file);
    if isfield( sun_W, 'tNewSource' )
        tNewSource = sun_W.tNewSource;
        tNewDestination = sun_W.tNewDestination;
        tNewWeights = sun_W.tNewWeights;
    else
        warning( '%s: no known field found\n', file );
        tNewSource = []; tNewDestination = []; tNewWeights = [];
    end
else
%     warning( '%s not found\n', file );
    tNewSource = []; tNewDestination = []; tNewWeights = [];
end
toc;