%Script used to demonstrate generation of different types of graph.
%
%
%6/4/03 - Leo Grady

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
% Date - $Id: connectGraphDemo.m,v 1.2 2003/08/21 17:29:29 lgrady Exp $
%========================================================================%

%Initialization
X=8;
Y=8;
radius=3;
newEdges=15;
levels=4;
neighbors=4;

%Generate a 4-connected lattice
[points1 edges1]=lattice(X,Y);

%Generate a 4-connected lattice
[points2 edges2]=lattice(X,Y,1);

%Generate a 4-connected lattice
[points3 edges3]=lattice(X,Y,radius);

%Generate a small-world lattice
edges4=addrandedges(newEdges,edges1);

%Generate a pyramid lattice
[levelChildren,levelIndex,points5,edges5,edgeBias,levels]= ...
    latticepyramid(X,Y,levels);

%Generate a triangulated point set
points6=rand(X*Y,2);
[dummy edges6]=knn(points6,neighbors);


%Display
subplot(3,2,1)
gplot(adjacency(edges1),points1,'k')
title('4-Connected lattice')
axis equal
axis tight
axis off

subplot(3,2,2)
gplot(adjacency(edges2),points2,'k')
title('8-Connected lattice')
axis equal
axis tight
axis off

subplot(3,2,3)
gplot(adjacency(edges3),points3,'k')
title('Radially donnected lattice')
axis equal
axis tight
axis off

subplot(3,2,4)
gplot(adjacency(edges4),points1,'k')
title('4-Connected small world lattice')
axis equal
axis tight
axis off

subplot(3,2,5)
gplot(adjacency(edges5),points5,'k')
title('Flattened pyramid lattice')
axis equal
axis tight
axis off

subplot(3,2,6)
gplot(adjacency(edges6),points6,'k')
title('Nearest-neighbor points')
axis equal
axis tight
axis off
