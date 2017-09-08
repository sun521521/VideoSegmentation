% Function to compute the gradient of the given optical flow
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

function result = getFlowGradient( flow )

    if( iscell( flow ) )
        
        frames = length(flow);
        for frame = 1:frames
        flowU(:, :, frame) = flow{1, frame}(:, :, 2); flowV(:, :, frame) = flow{1, frame}(:, :, 1);
        end
        
        flowU = single(flowU); flowV = single(flowV); 
        [grad.Ux, grad.Uy] =  gradient(flowU);
        [grad.Vx, grad.Vy] =  gradient(flowV);

%         gradU =  sun_gradient(flowU);
%         gradV =  sun_gradient(flowV);
%          
%         result = [gradU  gradU];
        result = grad;
    
    else
        [ height, width, anyvalue ] = size( flow );  %%%%%%%%%%%%%%%%%
        grad = zeros( height, width, 2, 'single' );
        if( ~isfloat( flow ) )
            flow = single( flow );
        end
        
        grad( :, :, 1 ) = gradient( flow( :, :, 1 ) );
        [ anyvalue, grad( :, :, 2 ) ] = gradient( flow( :, :, 2 ) );
        
        result = grad;  % 对 u 取 y 轴差分，对 v 取 x 轴差分
    end
end
