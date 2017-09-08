% Function to compute motion boundary probabilities base on optical flow
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

function [result, magnitude] = getProbabilityEdge( gradients, flowframe, mode, gradMu, gradSigma)

    if( ~exist( 'mode', 'var' ) || isempty( mode ) )
        mode = 3;
    end
    
    if( ischar( mode ) )
        if( strcmp( mode, 'gradient' ) )
            mode = 1;
        elseif( strcmp( mode, 'orientation' ) )
            mode = 2;
        elseif( strcmp( mode, 'gradient+orientation' ) )
            mode = 3;
        else
            error( 'Unknown or invalid mode selected' );
        end
    end

    if( ~exist( 'gradMu', 'var' ) || isempty( gradMu ) )
        gradMu = 0.5;
        gradSigma = 1.5;
    end
    
    if( mode == 1 )
        gradient = getFlowGradient( flowframe );
        magnitude = getMagnitude( gradient );

        result = 1 - exp( -gradLambda * magnitude );
    elseif( mode == 2 )
        result = getFlowDifference( flowframe );
    elseif( mode == 3 )                               %%%%%%%%%%%%%%%
        magnitude = getMagnitude( gradients );
        
        gradBoundary = normcdf( magnitude, gradMu, gradSigma);   % 论文中的 bp     
%         gradBoundary = sun_empirical(magnitude);
        
        rotBoundary = getFlowDifference( flowframe );  % 论文中的 b_theta     
        
        large = gradBoundary > 0.7 ;
        medium = gradBoundary <= 0.7 & gradBoundary > 0.4;  %  使用正态分布，不会到达0
        result = 0.1 * gradBoundary;
        
        result( large ) = gradBoundary( large );
        result( medium ) = ( gradBoundary( medium ) .* ...
            rotBoundary( medium ) );
%         result = gradBoundary.*rotBoundary;
        
        
    else
        error( 'Unknown or invalid mode selected' );
    end
    
end
