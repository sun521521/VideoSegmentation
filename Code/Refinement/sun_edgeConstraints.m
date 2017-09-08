function [consInSegments, consExSegments] = sun_edgeConstraints(appearanceUnaryMatrix, superpixels, locationUnaries, data, lamdaIn, lamdaEx)

edgePoints = data.edgePoints;
flow = data.flow;

consInSegments = []; consExSegments = [];
for i = 1:length(edgePoints)
    [inSegments exSegments] = sun_getInExSegments(locationUnaries, superpixels{i}, edgePoints{i}, lamdaIn, lamdaEx);
    
    for fInSegments= 1:length(inSegments)
        for bInSegments = fInSegments+1:length(inSegments)
            consInSegments = [consInSegments; [inSegments(fInSegments) inSegments(bInSegments)]];
        end
    end
    
    for fExSegments= 1:length(exSegments)
        for bExSegments = fExSegments+1:length(exSegments)
            consExSegments = [consExSegments; [exSegments(fExSegments) exSegments(bExSegments)]];
        end
    end
      
end

superpixels = []; 
superpixels = data.superpixels;
gradSet = [];
for frame = 1:length(flow)
    alpha = superPixelMeanFlowMagnitude( int16( 100 * ...    %  ???  先 *100，函数输入的要求。  梯度值太小
            getFlowGradient( flow{ frame } ) ), ...
            superpixels{ frame } ) / 100;
        
        gradSet = [gradSet; alpha];
end

if( exist( 'params', 'var' ) && isfield( params, 'lambda' ) )
    lambda = params.lambda;
else
    lambda = 2;   
end

probGrad = double( exp( - lambda * gradSet ) );        
probGrad = probGrad / 2/max( probGrad );  % 变换到 0 - 0.5之间

if isempty(appearanceUnaryMatrix)
    return;
end


probObject = appearanceUnaryMatrix(:, 1) / 2/max(appearanceUnaryMatrix(:, 1));  % 同上
probBackground = appearanceUnaryMatrix(:, 2)/ 2/ max(appearanceUnaryMatrix(:, 2));

if( exist( 'params', 'var' ) && isfield( params, 'beta' ) )
    beta = params.beta;
else
    beta = 0.08;   % 1.5
end

% 边缘内部
if ~isempty(consInSegments)
    inGradPart = sun_entropy(probGrad(consInSegments(:, 1)), probGrad(consInSegments(:, 2)));
    inAppearPart = sun_entropy(probObject(consInSegments(:, 1)), probObject(consInSegments(:, 2)));
    consInSegments(:, 3) =  beta*inGradPart + beta*inAppearPart;
end

% 边缘外部
if ~isempty(consExSegments)
    exGradPart = sun_entropy(probGrad(consExSegments(:, 1)), probGrad(consExSegments(:, 2)));
    exAppearPart = sun_entropy(probObject(consExSegments(:, 1)), probObject(consExSegments(:, 2)));
    consExSegments(:, 3) =  beta*exGradPart + beta*exAppearPart;
end
        
            