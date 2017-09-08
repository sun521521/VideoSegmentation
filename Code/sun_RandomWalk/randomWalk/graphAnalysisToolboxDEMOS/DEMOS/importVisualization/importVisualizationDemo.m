%Script used to demonstrate importing and visualization of an image onto a
%space-variant geometry.
%
%
%5/27/03 - Leo Grady

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
% Date - $Id: importVisualizationDemo.m,v 1.3 2003/08/21 17:46:03 lgrady Exp $
%========================================================================%

close all
clear

%Load image to import
img=im2double(imread('./../images/eslab0043.jpg'));
img=imresize(img,[256 320]); %Scale image to same size as structure
[X Y Z]=size(img);

%Load saved files
load ./../../SAVEDATA/animalVision/kangarooGrnd6400_256.mat

%Import image
vals=importimg(imgGraph,img);

%Visualize
figure
subplot(2,2,1)
imagesc(img)
title('Original image')
colormap(gray)
axis equal
axis tight
axis off

subplot(2,2,2)
gplot(adjacency(edges),points,'k')
title('Plains kangaroo structure')
axis equal
axis tight
axis off

subplot(2,2,3)
[edges, faces]=triangulatepoints(points);
showmesh(points,vals,faces)
title('Interpolated across triangulation')

subplot(2,2,4)
showvoronoi(vals,voronoiStruct)
title('Solid Voronoi cells')
