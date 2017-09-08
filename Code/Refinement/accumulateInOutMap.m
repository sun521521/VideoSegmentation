% Function to accumulate the inside ratios based on the optical flow
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

function [ result, tags ] = accumulateInOutMap( params, data )
    
    if( exist( 'params', 'var' ) && isfield( params, 'lambda' ) )
        lambda = params.lambda;
    else
        lambda = 2;   % 5     %  位置 L 中可信程度的 lanmda
    end
    
    flow = data.flow;
    superpixels = data.superpixels;
    map = data.inMaps;
    % connectivity：13 x 1 cell.每个cell为一个邻接矩阵，前一帧与后一帧的超像素块，元素为相交的像素个数
    connectivity = getSuperpixelConnectivity( flow, superpixels );

    spixelRatio = getSuperpixelInRatio( superpixels, map );  % 在前面的videoRapidSegment中，已经计算过
    
    frames = length( flow );
    
    % fprintf( 'Propagating metric forward...\n' );
    output = cell( frames, 1 );
    foreGain = cell( frames, 1 );
    output{ 1 } = double( spixelRatio{ 1 }' );   % 1x 1358
    foreGain{ 1 } = zeros( length( spixelRatio{ 1 } ), 1 ); % 1358 x 1
    
    for( frame = 1: frames - 1 )
          % 第frame帧做出的贡献
        % Find number of connections between superpixels
        connect = connectivity{ frame };  % 连通个数
        
        % Find the ratio of connections leading to a specific superpixel
        normFactor =  1 ./ sum( connect, 2 ); % sum( connect, 2 ): 前一帧每一个超像素块的面积
        % Check for inf - Turbopixels may return empty superpixel sets
        normFactor( isinf( normFactor ) ) = 0;
        normFactor = sparse( 1: length( normFactor ), ...
            1: length( normFactor ), normFactor );   
        connect = normFactor * connect;  % 前一帧的快与后一帧块的相似性   公式中的fai
        % alpha：1538 x 1
        alpha = superPixelMeanFlowMagnitude( int16( 100 * ...    %  ???  先 *100，函数输入的要求。  梯度值太小
            getFlowGradient( flow{ frame } ) ), ...
            superpixels{ frame } ) / 100;
%           % 修改
%         [inSegments exSegments] = sun_getInExSegments(  spixelRatio{frame}, superpixels{frame}, data.edgePoints{frame}, 0.2, 0.3);
%         alpha([inSegments exSegments]) = inf;
           %
        % This should be normalised for frame size   ????
%         alpha = double( exp( - lambda * alpha ) );
        alpha = double(1 - normcdf(alpha, 0, 0.15));
        
        alpha = sparse( 1: length( alpha ), 1: length( alpha ), alpha );

        alphaConnect = alpha * connect;  % 可信度 x 相似度
        
        sumAlphaConnect = sum(alphaConnect );  %% 修改
        
        foreGain{ frame + 1 } = ( output{ frame } * alphaConnect ) ./ sumAlphaConnect; % 往前，第二帧需要增加的量
        foreGain{ frame + 1 }( sumAlphaConnect == 0 ) = 0;
        foreGain{ frame + 1 } = foreGain{ frame + 1 }';
        output{ frame + 1 } = ( foreGain{ frame + 1 } + ...  % L2 + L2往前需要增加的  L1+0，更新完L2，计算L3需要增加的量
            double( spixelRatio{ frame + 1 } ) )';

    end

    % 在往前的基础上，进行往后，计算需要增加的量
    % fprintf( 'Propagating metric backward...\n' );
    backGain = cell( frames, 1 );
    output = cell( frames, 1 );
    output{ frames } = double( spixelRatio{ frames } );
    backGain{ frames } = zeros( length( spixelRatio{ frames } ), 1 );
    
    for( frame = frames - 1: -1: 1 )

        connect = connectivity{ frame };

        normFactor = 1 ./ sum( connect, 1 );
        % Check for inf - Turbopixels may return empty superpixel sets
        normFactor( isinf( normFactor ) ) = 0;
        normFactor = sparse( 1: length( normFactor ), ...
            1: length( normFactor ), normFactor );
        connect = connect * normFactor;

        alpha = superPixelMeanFlowMagnitude( int16( 100 * ...
            getFlowGradient( flow{ frame } ) ), ...
            superpixels{ frame } ) / 100;
%           % 修改
%         [inSegments exSegments] = sun_getInExSegments(  spixelRatio{frame}, superpixels{frame}, data.edgePoints{frame}, 0.2, 0.3);
%         alpha([inSegments exSegments]) = inf;
           %
%         alpha = double( exp( - lambda * alpha ) );
        alpha = double(1 - normcdf(alpha, 0, 0.15));
        alpha = sparse( 1: length( alpha ), 1: length( alpha ), alpha );

        alphaConnect = alpha * connect;
        
        sumAlphaConnect = sum( alphaConnect, 2 );  % 修改
        
        backGain{ frame } = ( alphaConnect * output{ frame + 1 } ) ./ sumAlphaConnect;
        backGain{ frame }( sumAlphaConnect == 0 ) = 0;

        output{ frame } = backGain{ frame } + double( spixelRatio{ frame } );

    end

    result = cell( frames, 1 );
    tags = cell( frames, 1 );
    
    for( i = 1: frames )
        tags{ i } = spixelRatio{ i } + foreGain{ i } + backGain{ i };  %  列向量
        
        result{ i } = tags{ i }( superpixels{ i } );  % 分配到超像素块
    end
    
end
