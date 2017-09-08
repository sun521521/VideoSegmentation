%Script used to demo the filtering operations on noisy coordinates given on
%a ring.
%
%
%5/13/03 - Leo Grady

% Copyright (C) 2002, 2003 Leo Grady <lgrady@cns.bu.edu>
%   Computer Vision and Computational Neuroscience Lab
%   Department of Cognitive and Neural Systems
%   Boston University
%   Boston, MA  02215
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
%
% Date - $Id: filterCoordDemo.m,v 1.2 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Parameters
iterations=120;
N=100;
noiseVar=.1;

%Create adjacency matrix for a ring
vec=sparse([0,1,zeros(1,N-3),1]);
W=circulant(vec);

%Create 2D coordinates for a ring
theta=linspace(0,2*pi-2*pi/N,N)';
points=[cos(theta),sin(theta)];

%Add radial noise
points=points+noiseVar*(randn(N,1)-.5)*ones(1,2).*points;

%Filter with lowpass mean filter
pointsAvg=filtergraph(W,points,iterations/10,[],1);

%Filter with lowpass Taubin filter
pointsLow=filtergraph(W,points,iterations,[.15 .3],1);

%Filter with highpass Taubin filter
rads=sum((points-pointsLow).^2,2);
rads=rads-min(rads);
rads=rads/max(rads);
pointsHigh=rads*ones(1,2).*points;

%Display 
figure
subplot(2,2,1)
gplot(W,points,'k')
axis equal
axis tight
title('Original corrupted circle')

subplot(2,2,2)
gplot(W,pointsAvg,'k')
axis equal
axis tight
title('Mean filtered signal')

subplot(2,2,3)
gplot(W,pointsLow,'k')
axis equal
axis tight
title('Taubin lowpass filtered signal')

subplot(2,2,4)
gplot(W,pointsHigh,'k')
axis equal
axis([-1 1 -1 1]);
title('Taubin highpass filtered signal')
