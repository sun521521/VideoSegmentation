% Function to auto-calibrate the motion bounds lambda weight
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

function bestEdges = calibrateProbabilityEdge(magnitude, flowframe, Mu, Sigma )

    epsilon = 0.1;

    % Starting edge sensitivity point
    if( ~exist( 'Mu', 'var' ) || isempty( Mu ) )
        Mu = 0.5;
        Sigma = 1.5;
    end
    
    [ height, width, anyvalue] = size( flowframe );
    
    rotBoundary = getFlowDifference( flowframe );
    
    bestQuality = -1;
    bestEdges = zeros( height, width );
    previousEdges = false( height, width );
    for( i = Sigma: -epsilon: 1.1 )

        edges = getEdge( magnitude, rotBoundary, Mu, i );   % 通过 Sigma 修正轮廓
        thresholdedEdges = edges > 0.5;
        
        if( thresholdedEdges == previousEdges )
            continue;
        else
            inPoints = getInPoints( thresholdedEdges, [], true );
            quality = getFrameQuality( inPoints > 4 );
            previousEdges = thresholdedEdges;
        end
        
        if( quality > bestQuality )
            bestQuality = quality;
            bestEdges = edges;
        end
    end
   
end

function result = getEdge( magnitude, rotBoundary, gradMu, gradSigma )

    gradBoundary = normcdf( magnitude, gradMu, gradSigma);     % 正态分布cdf，均值不变，方差越小，gradBoundary 越大 

    large = gradBoundary > 0.7 ;
    medium = gradBoundary <= 0.7 & gradBoundary > 0.4;
    result = 0.1 * gradBoundary;
    result( large ) = gradBoundary( large );
    result( medium ) = ( gradBoundary( medium ) .* ...
        rotBoundary( medium ) );
% result = gradBoundary.*rotBoundary;
end
