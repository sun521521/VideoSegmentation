% Function to compute the optical flow orientation difference value
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

function result = getFlowDifference( flow, rotMu, rotSigma)

    if( ~exist( 'rotMu', 'var' ) )
        rotMu = 0.04;
        rotSigma = 0.5;    % 0.5
    end

    [ height, width, anyvalue] = size( flow );
    if( ~isfloat( flow ) ), flow = single( flow ); end
    
    angles = atan2( flow( :, :, 2 ), flow( :, :, 1 ) );    
    angles( flow( :, :, 1 ) == 0 & flow( :, :, 2 ) == 0 ) = 10;
    
    dthetaMax = zeros( height, width, 'single' );
    dthetaMaxV = dthetaMax;
    dthetaMax( 1: end - 1, : ) =  min( abs( angles( 1: end - 1, : ) - ...
        angles( 2: end, : ) ),  abs( angles( 1: end - 1, : ) + ...
        angles( 2: end, : ) ) );
    dthetaMaxV( :, 1: end - 1 ) = min( abs( angles( :, 1: end - 1 ) - ...
        angles( :, 2: end ) ), abs( angles( :, 1: end - 1 ) + ...
        angles( : , 2: end ) ) );
    dthetaMax( 2: end, : ) = max( dthetaMax( 2: end, : ), ...
        dthetaMax( 1: end - 1, : ) );
    dthetaMaxV( :, 2: end ) = max( dthetaMaxV( :, 2: end ), ...
        dthetaMaxV( :, 1: end - 1 ) );
    dthetaMax = min( max( dthetaMax, dthetaMaxV ), pi );
    
    result = normcdf(dthetaMax .* dthetaMax, rotMu, rotSigma);
%      result = sun_empirical(dthetaMax .* dthetaMax);

end
