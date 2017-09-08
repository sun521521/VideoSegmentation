% Function to produce inside-outside maps of a shot given the optical flow
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

function [output, edgePoints] = getInOutMaps( flow )

    frames = length( flow );
    output = cell( frames, 1 );  edgePoints = cell( frames, 1 );

    [ height, width, anyvalue] = size( flow{ 1 } );
    
    % Motion boundaries touching the edges will be cut!
    sideCut = false( height, width );     % 四周都是 1  里面是0
    sideCut( 1: 15, : ) = true;
    sideCut( end - 15: end, : ) = true;
    sideCut( :, 1: 15 ) = true;
    sideCut( :, end - 15: end ) = true;
    
         gradient = getFlowGradient( flow );  % 计算光流体的所有梯度
%      results = getFlowGradient( flow );  % 计算光流体的所有梯度
%     gradientU = results(1);
%         gradientV = results(2);
    for( frame = 1: frames )
        % 该帧各个方向的梯度
        gradients(:, :, 1) = gradient.Ux(:, :, frame); gradients(:, :, 2) = gradient.Uy(:, :, frame); 
        gradients(:, :, 3) = gradient.Vx(:, :, frame); gradients(:, :, 4) = gradient.Vy(:, :, frame); 
           
%           Uname = fieldnames(gradientU);
%           for i = 1:8
%               temp = eval(sprintf('gradientU.%s', Uname{i}));
%               gradients(:, :, i) = temp(:, :, frame);
%           end
%           
%           Vname = fieldnames(gradientV);
%           for k = 1:8
%               temp = eval(sprintf('gradientV.%s', Vname{k}));
%               gradients(:, :, k+i) = temp(:, :, frame);
%           end
%           
%           
          
          
        [boundaryMap, magnitude] = getProbabilityEdge( gradients, flow{ frame }, 3 );  % 论文中的bp，表征：成为运动轮廓的概率 mode = 3

        % inVotes: 八条射线中，与轮廓点相交为奇数次的条数; edgePerFrame: 边界 (logical)
        [inVotes, edgePerFrame] = getInPoints( boundaryMap, sideCut, false ); 
        
        if( getFrameQuality( inVotes > 4 ) < 0.2 )   % 单一，紧密的目标，被认为是高质量的
            boundaryMap = calibrateProbabilityEdge(magnitude, flow{ frame }, 0.5, 1.5 );
            inVotes = getInPoints( boundaryMap, sideCut, false );
        end
        
        edgePoints{ frame } = edgePerFrame;
        
        % 均值滤波
        H = fspecial('gaussian', 5);
        inVotes = filter2(H, inVotes);
        
        output{ frame } = inVotes > 4;
    end    
    
end
