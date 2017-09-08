%Script used to demonstrate how to build the filters to allow importation
%onto an arbitrary point set.  Uses 2000 samples, uniformly chosen with a
%87040 pixel image.
%
%Note that building the filters for a set of points is a one-time cost.
%Consequently, this script is slightly time-consuming.
%
%
%5/15/03 - Leo Grady

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
% Date - $Id: buildFiltersDemo.m,v 1.2 2003/08/21 17:29:30 lgrady Exp $
%========================================================================%

%Parameters
N=1000;
X=256;
Y=320;

%Generate point set
points=[Y*rand(N,1),X*rand(N,1)];

%Import image
img=im2double(imread('./../images/eslab0043.jpg'));
img=imresize(img,[X Y]);

%Generate filters
[imgGraph,points]=findfilter(points,[Y X]);

%Find Voronoi structure for display
voronoiStruct=voronoicells(points);

%Import image to graph
vals=importimg(imgGraph,img);

%Display
figure
subplot(2,2,1) %Show point set
plot(points(:,1),points(:,2),'k.','MarkerSize',15)
axis equal
axis tight
title('Point set')

subplot(2,2,2) %Show empty voronoi cells
ph = patch('Vertices',voronoiStruct.pts,'Faces',voronoiStruct.faces);
set(ph, 'FaceVertexCData', ones(N,3));
set(ph,'FaceColor', 'flat');
warning off %Avoids persistant warning 
%   "RGB not yet supported in Painter's Mode"
axis equal
axis tight
axis off
warning on
title('Voronoi cells')

subplot(2,2,3) %Show original image
imagesc(img)
axis image
axis off
title('Original Image')

subplot(2,2,4) %Show voronoi cells with vals
showvoronoi(vals,voronoiStruct);
title('Imported Image - 2000 samples vs. 81920 pixels')
