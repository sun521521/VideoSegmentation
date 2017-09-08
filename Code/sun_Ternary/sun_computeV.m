function [sNewSource, sNewDestination, sNewWeights] = sun_computeV(options, superpixels, colours, centres, labels,foregroundMasks )

folder = fullfile( options.outfolder, 'processing' );
if( ~exist( folder, 'dir' ) )
    mkdir( folder );
end
 filename = fullfile( folder, sprintf( 'sun_V.mat' ) );



[ sSource, sDestination ] = ...  %  sSource， sDestination：都是列向量
        getSpatialConnections( superpixels, labels );
    sSource = sSource + 1;  sDestination =  sDestination + 1;
    
    % 构建上和左两个方向的邻接点
    temp_sSource = sSource;     temp_sDestination = sDestination; 
        sSource  = [sSource; temp_sDestination];
        sDestination  = [sDestination; temp_sSource];

% 构建超边关系
uniqueDestination = unique( sDestination ); 
ternaryElements = [];
for i = 1:length( uniqueDestination )
    tempIndex = find( sDestination == uniqueDestination(i) );
    tempIdx = find( sSource == uniqueDestination(i) );
    
    tempBox = zeros(length(tempIdx)*length(tempIndex), 3, 'uint32');

    [X, Y] = meshgrid( sSource(tempIndex), sDestination(tempIdx) );
    tempBox(:, 1) = reshape(X, [], 1); tempBox(:, 2) = uniqueDestination(i);
    tempBox(:, 3) = reshape(Y, [], 1);

    ternaryElements = [ternaryElements; tempBox];
end

% 剔除重复邻接点(上 左)
idx = ternaryElements(:, 1) == ternaryElements(:, 2) | ternaryElements(:, 1) == ternaryElements(:, 3) | ternaryElements(:, 2) == ternaryElements(:, 3);
ternaryElements = ternaryElements(~idx, :);

ternarySource = ternaryElements(:, 1); ternaryBridge = ternaryElements(:, 2); ternaryDestination = ternaryElements(:, 3);
[totalColours(:, :, 1), totalColours(:, :, 2), totalColours(:, :, 3)] = deal( colours(ternarySource, :),  colours(ternaryBridge , :),  colours(ternaryDestination , :));
averageColours = mean(totalColours, 3);

sColourDistance = sum([( colours( ternarySource, : ) - averageColours( :, : ) ) .^ 2, ...
                    ( colours(  ternaryBridge, : ) - averageColours( :, : ) ) .^ 2, ...
                    ( colours( ternaryDestination, : ) - averageColours( :, : ) ) .^ 2], 2)/3;

[totalCentres(:, :, 1), totalCentres(:, :, 2), totalCentres(:, :, 3)] = deal( centres(ternarySource, :),  centres(ternaryBridge, :),  centres(ternaryDestination, :));
averageCentres = mean(totalCentres, 3);
                

sCentreDistance = sqrt(sum([(  centres( ternarySource, : ) - averageCentres( :, : ) ) .^ 2, ...
                    ( centres(  ternaryBridge, : ) - averageCentres( :, : ) ) .^ 2, ...
                    ( centres( ternaryDestination , : ) - averageCentres( :, : ) ) .^ 2], 2)/3);
                
denominator = sColourDistance ./ sCentreDistance;
sBeta = 1 / mean( denominator(foregroundMasks(ternarySource) | foregroundMasks(ternaryBridge) | foregroundMasks(ternaryDestination)) ); 
% sBeta = sun_learnBeta( options, superpixels,  sSource, sDestination, 1./ sCentreDistance, sColourDistance, sBeta, 'V');


sWeights = exp( -sBeta * sColourDistance ) ./ sCentreDistance;

% 模板外的节点，赋予一个极大的值 
sWeights(~( foregroundMasks(ternarySource) | foregroundMasks(ternaryBridge) | foregroundMasks(ternaryDestination) )) = inf;  % 30


sBinaryElements = zeros( length(sWeights) * 3, 2, 'uint64');
sBinaryWeights = zeros( length(sWeights) * 3, 1, 'single');

sBinaryElements(1:3:end, :) = [ternarySource, ternaryBridge]; sBinaryElements(2:3:end, :) = [ternaryBridge, ternaryDestination];
sBinaryElements(3:3:end, :) = [ternarySource, ternaryDestination];
sBinaryWeights(1:3:end, :) = sWeights ; sBinaryWeights(2:3:end, :) = sWeights; sBinaryWeights(3:3:end, :) = sWeights;

% 调整为上三角 上 左
tempIndex = find(sBinaryElements(:, 1) > sBinaryElements(:, 2));
% 交换
sBinaryElements(tempIndex, 1) = sBinaryElements(tempIndex, 1) + sBinaryElements(tempIndex, 2);
sBinaryElements(tempIndex, 2) = sBinaryElements(tempIndex, 1) - sBinaryElements(tempIndex, 2);
sBinaryElements(tempIndex, 1) = sBinaryElements(tempIndex, 1) - sBinaryElements(tempIndex, 2);


sVectorElementsTotal = sub2ind([labels, labels], sBinaryElements(:, 1) ,sBinaryElements(:, 2));

% 筛选最初的节点对
sVector = sub2ind([labels, labels], sSource ,sDestination);
sVector = uint64(sVector);
sVectorElements = sVectorElementsTotal (ismember(sVectorElementsTotal , sVector));
sBinaryWeights = sBinaryWeights(ismember(sVectorElementsTotal , sVector));

% % 'descend'  求最大值
% [sBinaryWeights, index] = sort(sBinaryWeights,'descend'); sVectorElements = sVectorElements( index );  
% [sVectorElements, index2] = sort(sVectorElements); sBinaryWeights = sBinaryWeights( index2 );  
% [sVectorElements, minValuesIndex] = unique( sVectorElements ); sBinaryWeights = sBinaryWeights( minValuesIndex );

% 求平均
[sVectorElements, index] = sort(sVectorElements );

[sBinaryElem(:, 1), sBinaryElem(:, 2)] = ind2sub([labels, labels], sVectorElements);
% sBinaryElements = sBinaryElements(index, :);
sBinaryWeights = sBinaryWeights( index );
sBinaryWeights(sBinaryWeights==0) = eps;
sparseFormat = sparse(double(sBinaryElem(:, 1)), double(sBinaryElem(:, 2)), double(sBinaryWeights));
[sNewSource, sNewDestination, sumWeights] = find( sparseFormat );
[anyvalues3, relativeLocations] = unique(sVectorElements);
numOfweights = [diff(relativeLocations); length(sVectorElements) - relativeLocations(end)+1];
sBinaryWeights = sumWeights ./ numOfweights;

sNewWeights = single(sBinaryWeights);
sNewDestination = uint32(sNewDestination) - 1;  % c语言下标从0开始
sNewSource =  uint32(sNewSource)-1;


% [sNewSource, sNewDestination]  = ind2sub([labels, labels], sVectorElements);
% % sNewDestination = fix( double(sVectorElements)/labels ) + 1;
% % % sNewSource = sVectorElements - (sNewDestination-1) *labels;
% % sNewSource = mod(double(sVectorElements), labels);
% 
% sNewWeights = sBinaryWeights;
% sNewDestination = uint32(sNewDestination) - 1;  % c语言下标从0开始
% sNewSource =  uint32(sNewSource)-1;
save( filename, 'sNewSource', 'sNewDestination', 'sNewWeights');
