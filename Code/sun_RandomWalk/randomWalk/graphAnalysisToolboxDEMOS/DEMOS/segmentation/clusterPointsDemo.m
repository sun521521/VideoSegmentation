%Script used to cluster a set of points in the plane.
%
%
%6/5/03 - Leo Grady

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
% Date - $Id: clusterPointsDemo.m,v 1.3 2003/08/21 17:29:30 lgrady Exp $
%========================================================================%

%Initialization
N=300;
offset1=[5,0];
offset2=[10,0];
geomScale=95;
stop=1e-3;

%Generate random point set
points=[randn(N/3,2);randn(N/3,2)+ones(N/3,1)*offset1; ...
        randn(N/3,2)+ones(N/3,1)*offset2];

%Connect points
[edges,faces]=triangulatepoints(points);

%Generate adjacency matrix
weights=makeweights(edges,[],0,points,geomScale);
W=adjacency(edges,weights);

%Perform clustering (segmentation)
segAnswer=recursivepartition(W,stop);

%Display
figure
subplot(3,1,1)
plot(points(:,1),points(:,2),'ko')
axis equal
axis tight
title('Original, random point set')

subplot(3,1,2)
gplot(W,points)
axis equal
axis tight
title('Connected point set')

subplot(3,1,3)
index1=find(segAnswer==0);
index2=find(segAnswer==1);
index3=find(segAnswer==2);
plot(points(index1,1),points(index1,2),'ro')
hold on
plot(points(index2,1),points(index2,2),'bo')
plot(points(index3,1),points(index3,2),'go')
hold off
axis equal
axis tight
title('Clustered point set')
