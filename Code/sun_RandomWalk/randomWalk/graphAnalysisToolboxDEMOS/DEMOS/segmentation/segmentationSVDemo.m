%Script used to demo space variant segmentation
%
%
%5/6/03 - Leo Grady

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
% Date - $Id: segmentationSVDemo.m,v 1.5 2003/08/21 17:46:03 lgrady Exp $
%========================================================================%

%Parameters
valsScale=95;
geomScale=15;
stop=1e-5;

%Load image
img=im2double(imread('./../images/eslab0043.jpg'));
img=imresize(img,[256,320]); %Resize to a more manageable size
[X Y Z]=size(img);

%Load sloth data
load ./../../SAVEDATA/animalVision/sloth6400_256.mat
N=size(points,1);

%Import image to graph
vals=importimg(imgGraph,img);

%Generate weights
weights=makeweights(edges,vals,valsScale,points,geomScale);

%Build Adjacency graph
W=adjacency(edges,weights);

%Perform segmentation
segAnswer=recursivepartition(W,stop);

%Create markup for display
[valsOutline,valsMarkup]=segoutputSV(edges,vals,segAnswer);

%Display
figure
subplot(3,2,1)
imagesc(img)
colormap(gray)
axis equal
axis tight
axis off
title('Original: ESLab0043')

subplot(3,2,2)
gplot(W,points,'k')
axis equal
axis tight
axis off
title('Sloth Structure')

subplot(3,2,3)
showvoronoi(vals,voronoiStruct)
title('Imported Image')

subplot(3,2,4)
showvoronoi(segAnswer,voronoiStruct)
title('Segment Labels')

subplot(3,2,5)
showvoronoi(valsOutline,voronoiStruct)
title('Segmentation Outline')

subplot(3,2,6)
showvoronoi(valsMarkup,voronoiStruct)
title('Segmentation Markup')
