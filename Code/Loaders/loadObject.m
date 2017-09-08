function objectPossibility  = loadObject( options, i)

tic; fprintf( '\t\t\t load objectPossibility_%d...\t\t', i);

file = fullfile( options.outfolder, 'objectPossibility', sprintf( 'objectPossibility_%d.mat', i ) );

if exist( file, 'file' )
    
    sun_objectPossibility  = load(file);
    if isfield(sun_objectPossibility, 'objectPossibility' )
        objectPossibility = sun_objectPossibility.objectPossibility;
    else
        warning( '%s: no known field found\n', file );
        objectPossibility = [];
    end
else
%     warning( '%s not found\n', file );
    objectPossibility = []; 
end
toc;