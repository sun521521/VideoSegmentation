% Function that implements the Video Rapid Segment algorithm
%
%    Copyright (C) 2013  Anestis Papazoglou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: a.papazoglou@sms.ed.ac.uk

function segmentation = videoRapidSegment( options, params, data)
    
    % Params parsing
    if( ~isfield( params, 'locationWeight1' ) || ...
        isempty( params.locationWeight1 ) )
        params.locationWeight = 50;
    end
    
    if( ~isfield( params, 'spatialWeight' ) || ...
        isempty( params.spatialWeight ) )
        params.spatialWeight = 5000;
    end
    
    if( ~isfield( params, 'temporalWeight' ) || ...
        isempty( params.temporalWeight ) )
        params.temporalWeight = 4000;
    end
    
    if( ~isfield( params, 'fadeout' ) || isempty( params.fadeout ) )
        params.fadeout = 0.0001;
    end
    
    if( ~isfield( params, 'maxIterations' ) || ...
        isempty( params.maxIterations ) )
        params.maxIterations = 4;
    end
    
    if( isfield( params, 'foregroundMixtures' ) && ...
        ~isempty( params.foregroundMixtures ) )
        fgMix = params.foregroundMixtures;
    else
        fgMix = 5;
    end
    
    if( isfield( params, 'backgroundMixtures' ) && ...
        ~isempty( params.backgroundMixtures ) )
        bgMix = params.backgroundMixtures;
    else
        bgMix = 8;
    end
   % 以上参数包含在getDefaultParams（）中
   
    if( isfield( params, 'locationNorm' ) && ...
        ~isempty( params.locationNorm ) )
        locationNorm = params.locationNorm;
    else
        locationNorm = 0.75;
    end
    
    if( ~isfield( options, 'visualise' ) || isempty( options.visualise ) )
        options.visualise = false;
    end
    
    if( ~isfield( options, 'vocal' ) || isempty( options.vocal ) )
        options.vocal = false;
    end
    % End of params parsing
    
    flow = data.flow;
    superpixels = data.superpixels;
    
    % Compute inside-outside maps  （3.1）
    if( options.vocal ), tic; fprintf( 'videoRapidSegment: Computing inside-outside maps...\t' ); end
     % data.edgePoints: 边界 (logical)
    [data.inMaps, data.edgePoints] = getInOutMaps( flow );    % data.inMaps： 13 x 1 cell  (logical) 只有内部，去掉了边
    inRatios = getSuperpixelInRatio( superpixels, data.inMaps );  % 交集占超像素块的比例
   %
%     data.inMaps = sun_inMaps(inRatios, superpixels, data.inMaps);  % 修改
%     inRatios = getSuperpixelInRatio( superpixels, data.inMaps );
   %
    if( options.vocal ), toc; end
    
    imgs = data.imgs;
    frames = length( flow );
    
   
    % 赋予14 x 1 cell的超像素块统一标号。 labels： 一个 double 整数，是最大标号
    % nodeFrameId:列向量，超像素块总的个数 x 1
    [ superpixels, nodeFrameId, bounds, labels ] = ...  
        makeSuperpixelIndexUnique( superpixels );

    % 得到所有超像素块的平均颜色（彩色），几何中心
    % colours：single类型列向量，超像素块总的个数 x 3
    % centres：single类型列向量，超像素块总的个数 x 2
    [ colours, centres, area] = ...
        getSuperpixelStats( imgs, superpixels, labels );
      sun_colours  = colours;
      
    % 二元势
    
   
    colours = uint8( round( colours ) );
    
    % Preallocate space for unary potentials
    nodes = size( colours, 1 );
    unaryPotentials = zeros( nodes, 2 );

    % Create location priors   
    if( options.vocal ), tic; fprintf( 'videoRapidSegment: Computing location priors...\t\t' ); end
    % 对于L，往前，往后遍历两遍，增加相似度
    [ anyvalue, accumulatedInRatios ] = accumulateInOutMap( params, data );  % 往前往后更新完，得出每个超像素块的累积相似度
    locationMasks = cell2mat( accumulatedInRatios );  % 前13帧，未标准化的位置势能，表征靠近目标的程度
    
    locationUnaries = 0.5 * ones( nodes, 2, 'single' );

    locationUnaries( 1: length( locationMasks ), 1 ) = ... %% 
        locationMasks / ( locationNorm * max( locationMasks ) );  % 标准化
    locationUnaries( locationUnaries > 0.95 ) = 0.999;  
    
    for( frame = 1: frames )% 对每一帧中的位置势能，进行调整
        start = bounds( frame );
        stop = bounds( frame + 1 ) - 1;
        
        frameMasks = locationUnaries( start: stop, 1 );
        overThres = sum( frameMasks > 0.6 ) / single( ( stop - start + 1) );

        if( overThres < 0.05 )
            E = 0.005;
        else
            E = 0.000;
        end
        locationUnaries( start: stop, 1 ) = ...
            max( locationUnaries( start: stop, 1 ), E );
        
    end
    locationUnaries( :, 2 ) = 1 - locationUnaries( :, 1 );
    
    if( options.vocal ), toc; end
    % 位置势能完毕，只有前13帧，最后一帧 列1，列2都为0.5。第一列表征距离目标远近， 两列相差较大
    
    masks = 0.19 * ones( nodes, 1 );
    % inRatios: cell  13 x 1;一个cell中的数为每个超像素块占内部图的比例
%     masks( 1: bounds( frames + 1 ) - 1 ) = single( cell2mat( inRatios ) );
        % 修改
        masks( 1: bounds( frames + 1 ) - 1 ) = single( cell2mat( inRatios ) );

    % Create binary masks for foreground/background initialisation
    foregroundMasks = masks > 0.2;  % 由占内部图的比例，得到的最初的前景标签(分割) (19705 x 1)   firstSeg.jpg
    backgroundMasks = masks < 0.05; % 最后一帧既不是前景，也不是背景 0.19
    
    % 修改
%     [totalInSegments, totalExSegments] = sun_getTotalInExsegments(locationUnaries, superpixels, data.edgePoints, 0.55, 0.7);
%     foregroundMasks([totalInSegments, totalExSegments]) = 0;  backgroundMasks([totalInSegments, totalExSegments]) = 0;
    %
    
    % Create fading frame weight
    if( options.vocal ), tic; fprintf( 'videoRapidSegment: Neighbour frame weighting...\t\t' ); end
    weights = zeros( 1 + 2 * frames, 1, 'single' );
    middle = frames + 1;
    for( i = 1: length( weights ) )
        weights( i ) = exp( - params.fadeout * ( i - middle ) ^ 2 );  % 27 x 1
    end
    if( options.vocal ), toc; end

   
    fgColors = colours( foregroundMasks, : );
    bgColors = colours( backgroundMasks, : );
    
    % 修改
    potentialMatrix.appearance = zeros( nodes, 2 );
    potentialMatrix.location = zeros( nodes, 2 );
    potentialMatrix.LA = zeros( nodes, 2 );

    %
    for ( frame = 1: frames )
        
        ids = nodeFrameId - frame + middle;
        
        fgNodeWeights = masks( foregroundMasks ) .* ...
            weights( ids( foregroundMasks ) );   % 对于前景：  占内部图的比例 x 远近
        bgNodeWeights = ( 1 - masks( backgroundMasks ) ) .* ...
            weights( ids( backgroundMasks ) );

        [ uniqueFgColours, fgNodeWeights ] = ...
            findUniqueColourWeights( fgColors, fgNodeWeights );  %%%%  ???
        [ uniqueBgColours, bgNodeWeights ] = ...
            findUniqueColourWeights( bgColors, bgNodeWeights );
        
        startIndex = bounds( frame );
        stopIndex = bounds( frame + 1 ) - 1;
        
        if( size( uniqueFgColours, 1 ) < fgMix || ...
            size( uniqueBgColours, 1 ) < bgMix )  
        % 若前景或者背景像素太少，无法估计GMM。则单节点势能统一取 -log(0.5)
            warning( 'Too few data points to fit GMM...\n' ); %#ok<WNTAG>
            unaryPotentials( startIndex: stopIndex, : ) = -log( 0.5 );
        else
            % 训练该帧的前景模型和计算节点的概率密度，需要用到整个视频体的信息
            [ fgModel ] = fitGMM( fgMix, uniqueFgColours, fgNodeWeights );
                  % fgMix 前景混合高斯模型中，单高斯模型的个数
                  % fgNodeWeights 由距离远近和 r ，算出来的权重
            [ bgModel ] = fitGMM( bgMix, uniqueBgColours, bgNodeWeights );

            appearanceUnary = getUnaryAppearance( single( colours( nodeFrameId == frame, : ) ), fgModel, bgModel );
                % 因为做运算，所以转换为single（float）类型
                % appearanceUnary   大小：该帧的节点数 x 2。每个节点表征 是前景和背景的可能性
                
                % 修改
%                 appearanceUnaryMatrix = [appearanceUnaryMatrix; appearanceUnary ];
                % 
                
                tempLocationUnaries = locationUnaries( startIndex: stopIndex, : );
%                 tempLocationUnaries(tempLocationUnaries == 0, 1) = min(tempLocationUnaries(tempLocationUnaries(:,1)  ~= 0, 1));
%                   tempLocationUnaries = locationUnaries(startIndex: stopIndex, :);

                laUnary = sun_getUnaryLA(double(tempLocationUnaries), appearanceUnary);
                
                % 累加 potentialMatrix
               potentialMatrix.appearance( startIndex: stopIndex, :) = appearanceUnary;
               potentialMatrix.location( startIndex: stopIndex, :) = tempLocationUnaries;
                potentialMatrix.LA( startIndex: stopIndex, :) = laUnary ;
           
            unaryPotentials( startIndex: stopIndex, : ) = -params.locationWeight1 * log(tempLocationUnaries ) + ...
                -params.appearanceWeight1*log( appearanceUnary )+...
                -params.laWeight1*log( laUnary );
            % locationUnaries 大小：所有帧的节点数 x 2 （每行都有具体的值）
            % 第一列表征该节点与内部图的相似性（覆盖比例+更新部分）；第二列为：1 - 第一列数值
            % unaryPotentials：只到13帧.最后一帧的unaryPotential只有 0 0
        end
    end
    
       % 疑似前景区域
 potentialMatrix.appearance = -log(potentialMatrix.appearance);
 potentialMatrix.location= -log(potentialMatrix.location);
 potentialMatrix.LA = -log(potentialMatrix.LA);
 appearance = mapBelief( potentialMatrix.appearance ); location = mapBelief( potentialMatrix.location );  LA = mapBelief(  potentialMatrix.LA  );
 
  foreground = appearance./maxmax(appearance) >= 0 |  location./maxmax(location) >= 0  |  LA./maxmax( LA ) >= 0;
     
    
    
    
     % 修改
%     [consInSegments, consExSegments] = sun_edgeConstraints(appearanceUnaryMatrix, superpixels, locationUnaries, data, 0.2, 0.3);
%     pairPotentials = sun_updatePairwisePotentials (params, pairPotentials, consInSegments, consExSegments);
    
 % Compute pairwise potentials
    if( options.vocal ),  fprintf( 'videoRapidSegment: Computing pairwise potentials: \n' ); end
%     pairPotentials = computePairwisePotentials( params, superpixels, ...
%         flow, colours, centres, labels );
    [pairPotentials, vNumbers]= sun_computeTernaryPotentials(  options,params, superpixels, flow, sun_colours,...
      centres, labels ,bounds, nodeFrameId, potentialMatrix, data);
  potentialMatrix = [];  
  
  % 更新 unaryPotentials，分出疑似前景区域
  unaryPotentials( ~foreground, 1) = inf;  % 极大数  -log(5e-100)*30
  unaryPotentials( ~foreground, 2) = eps ;  %  -log(1-5e-100)*30 
  unaryPotentials(bounds(end-1):bounds(end)-1, : ) = 0;
  
   % Initialise segmentations
    if( options.vocal ), tic; fprintf( 'videoRapidSegment: Computing initial segmentation...\t' ); end
    [ anyvalue, labels ] = maxflow_mex_optimisedWrapper( pairPotentials, ...
        single( unaryPotentials ) );   % 初始化分割。 为什么单节点势能还要乘以10？

    segmentation = superpixelToPixel( labels, superpixels ); %%%%%%%%% 可删
       % 输入：具有唯一索引的 labels 和 superpixels
    if( options.vocal ), toc; end
    
    % Check that we did not get a trivial, all-background/foreground
    % segmentation
    if( all( labels ) || all( ~labels ) )
        if( options.vocal ), fprintf( 'videoRapidSegment: Trivial segmentation detected, exiting...\n' ); end
        return;
    end
    
    sun_oldLabels = labels;
    % Iterating segmentations
    for( i = 2: params.maxIterations )
        if( options.vocal ), tic; fprintf( 'videoRapidSegment: Iteration: %d...\t\t\t\n', i ); end
        
        fgColors = colours( labels, : ); 
        % 按照索引取值分两类：
        % 1.索引为逻辑值0/1，则从上往下，只取逻辑值为 1 的值；
        % 2. 索引为标号，取相应标号的值 
        
        bgColors = colours( ~labels, : );
            oldLabels = labels;
            
      % 修改
    potentialMatrix.appearance = zeros( nodes, 2 );
    potentialMatrix.location = zeros( nodes, 2 );
    potentialMatrix.LA = zeros( nodes, 2 );
        for( frame = 1: frames )
            ids = nodeFrameId - frame + middle;

            fgNodeWeights = weights( ids( labels ) );  % 对于前景：权重值与远近有关
            bgNodeWeights = weights( ids( ~labels ) );

            [ uniqueFgColours, fgNodeWeights ] = ...
                findUniqueColourWeights( fgColors, fgNodeWeights );
            [ uniqueBgColours, bgNodeWeights ] = ...
                findUniqueColourWeights( bgColors, bgNodeWeights );

            if( size( uniqueFgColours, 1 ) < fgMix || ...
                size( uniqueBgColours, 1 ) < bgMix )
                warning( 'videoRapidSegment: Too few data points to fit GMM...\n' ); %#ok<WNTAG>
                return;
            end
            
            [ fgModel ] = fitGMM( fgMix, uniqueFgColours, fgNodeWeights );  % fgModel:混合高斯模型的参数
            [ bgModel ] = fitGMM( bgMix, uniqueBgColours, bgNodeWeights );
            
            appearanceUnary = getUnaryAppearance( ...
                single( colours( nodeFrameId == frame, : ) ), ...
                fgModel, bgModel );
            % 得到外观模型：每帧节点个数 x 2(即：fg bg) 1:13

            startIndex = bounds( frame );
            stopIndex = bounds( frame + 1 ) - 1;

            % 修改
               tempLocationUnaries = locationUnaries( startIndex: stopIndex, : );
%                 tempLocationUnaries(tempLocationUnaries == 0, 1) = min(tempLocationUnaries(tempLocationUnaries(:,1)  ~= 0, 1));
%                   tempLocationUnaries = locationUnaries(startIndex: stopIndex, :);


                laUnary = sun_getUnaryLA(double(tempLocationUnaries), appearanceUnary);
                
                % 累加 potentialMatrix
               potentialMatrix.appearance( startIndex: stopIndex, :) = appearanceUnary;
               potentialMatrix.location( startIndex: stopIndex, :) = tempLocationUnaries;
                potentialMatrix.LA( startIndex: stopIndex, :) = laUnary ;
           
                
                
            unaryPotentials( startIndex: stopIndex, : ) = -params.locationWeight2 * log(tempLocationUnaries ) + ...
                -params.appearanceWeight2*log( appearanceUnary ) +...
                -params.laWeight2*log( laUnary );
   
        end

         
    % 疑似前景区域
 potentialMatrix.appearance = -log(potentialMatrix.appearance);
 potentialMatrix.location= -log(potentialMatrix.location);
 potentialMatrix.LA = -log(potentialMatrix.LA);
 appearance2 = mapBelief( potentialMatrix.appearance ); location2 = mapBelief( potentialMatrix.location );  LA2 = mapBelief(  potentialMatrix.LA  );
 
  foreground2 = appearance2./maxmax(appearance2) >= 0 |  location2./maxmax(location2) >= 0  |  LA2./maxmax( LA2 ) >= 0;
        % 7  5 7
       %%% 添加
%             objectPossibility = loadObject( options, i);
%     if( isempty( objectPossibility ) )
          if( options.vocal ), tic; fprintf( '\t\tComputing objectPossibility...\t' ); end
       objectPossibility = sun_objectPossibility(options,bounds, sun_oldLabels,  potentialMatrix, superpixels, pairPotentials, vNumbers, params, data, i);
            if( options.vocal ), toc; end
%     end
       unaryPotentials = unaryPotentials  - params.objectWeight * log(objectPossibility);

         % 更新 unaryPotentials，分出疑似前景区域
          unaryPotentials( ~foreground2, 1) = inf;  % 极大数  -log(5e-100)*30
          unaryPotentials( ~foreground2, 2) = eps;  % -log(1-5e-100)*30
          unaryPotentials(bounds(end-1):bounds(end)-1, : ) = 0;
%       
        [ anyvalue, labels ] = maxflow_mex_optimisedWrapper( pairPotentials, ...
            single( unaryPotentials ) );
        segmentation = superpixelToPixel( labels, superpixels );  %  可删
        
        if( options.vocal ), toc; end
        
        if( ( i == params.maxIterations ) |...
             all( oldLabels == labels ) ) 

            if( options.vocal ), fprintf( 'videoRapidSegment: Convergence or maximum number of iterations reached\n' ); end

            if( options.visualise )
                if( options.vocal ), tic; fprintf( 'videoRapidSegment: Creating segmentation video...\t' ); end

                videoParams.name = sprintf( 'segmentation%d', data.id );  % 创建结构数组  videoParams
                videoParams.range = data.id;
                mode = 'ShowProcess';

                data.locationProbability = superpixelToPixel( ...
                    locationUnaries( :, 1 ), superpixels );  % 每个像素点上都有一个位置势能 14 x 1，locationUnaries的第一列，表征距离内部图的远近
               
                if min(min(objectPossibility)) < 0
                    objectPossibility = objectPossibility - min(min(objectPossibility));  %% 为了显示，平移数据到原点
                end
                data.objectPossibility1 = superpixelToPixel( ...
                    objectPossibility( :, 1 ), superpixels ); 
                data.objectPossibility2 = superpixelToPixel( ...
                    objectPossibility( :, 2 ), superpixels ); 
                
                
                if min(min(potentialMatrix.LA)) < 0
                    potentialMatrix.LA = potentialMatrix.LA - min(min(potentialMatrix.LA));  %% 为了显示，平移数据到原点
                end
                data.LA = mapBelief( superpixelToPixel( ...
                    potentialMatrix.LA, superpixels ) ); 
                % 伪背景/（伪前景+伪背景）  ~ 表征成为前景的比重
                % 每个像素上都有一个外观势能的 -log（前，背） height x width x ndims
                % 倒数第二帧（13）得到的fgModel
                app = getUnaryAppearance( single( colours ), fgModel, bgModel );
                data.appearanceProbability = mapBelief( ... 
                    superpixelToPixel( - log( single(  app ) ), superpixels ) );   
               
                % 综合 locationProbability 和 appearanceProbability，表征了成为前景的比重
                % 第二列/（第一列+第二列）
                if min(min(unaryPotentials)) < 0
                    unaryPotentials = unaryPotentials - min(min(unaryPotentials));  %% 为了显示，平移数据到原点
                end
                unaryPotentials(isinf(unaryPotentials)) = maxmax(unaryPotentials(~isinf(unaryPotentials)));
                data.unaryPotential = mapBelief( superpixelToPixel( ...
                    unaryPotentials, superpixels ) );   

                data.segmentation = segmentation;

                createSegmentationVideo( options, videoParams, data, mode ,'initial');

                videoParams.name = sprintf( 'segmentation%d-dominantObject', data.id );
                data.segmentation = getLargestSegmentAndNeighbours( ...
                    segmentation );
                createSegmentationVideo( options, videoParams, data, mode ,'dominant');
                clear data

                if( options.vocal ), toc; end
            end
            
            break;
        end
        
        % Check that we did not get a trivial, all-background/foreground
        % segmentation
        if( all( labels ) || all( ~labels ) )
            if( options.vocal ), fprintf( 'videoRapidSegment: Trivial segmentation detected, exiting...\n' ); end
            return;
        end
        
    end

    if( options.vocal ), fprintf( 'videoRapidSegment: Algorithm stopped after %d iterations.\n', i ); end

end
