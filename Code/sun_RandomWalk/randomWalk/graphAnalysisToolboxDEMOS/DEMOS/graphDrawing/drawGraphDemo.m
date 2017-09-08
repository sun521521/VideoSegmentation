%Script used to demo graph drawing such that each point is at the center of
%its neighbors
%
%
%5/5/03 - Leo Grady

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
% Date - $Id: drawGraphDemo.m,v 1.2 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Generate 2D random points, choose extremal points to fix and "interpolate"
%interior points
N=500;
threshhold=.47; %Chosen because it "looks good"

%Generate graph
points=rand(N,2)-.5;
[edges,faces]=triangulatepoints(points);

%Find extremal points
r=max(abs(points),[],2);
boundary=find(r>threshhold);

%Interpolate the interior nodes
L=laplacian(edges);
newPoints=dirichletboundary(L,boundary,points(boundary,:));

%Display
figure
W=adjacency(edges);
subplot(2,1,1)
gplot(W,points,'k');
hold on
%Mark boundary points
plot(points(boundary,1),points(boundary,2),'k.','MarkerSize',24) 
hold off
title('Random points and chosen boundary points')
axis equal
axis tight
axis([-.5 .5 -.5 .5])

subplot(2,1,2)
gplot(W,newPoints,'k');
hold on
%Mark boundary points
plot(newPoints(boundary,1),newPoints(boundary,2),'k.','MarkerSize',24) 
hold off
title('Smoothed internal points')
axis equal
axis tight
axis([-.5 .5 -.5 .5])
