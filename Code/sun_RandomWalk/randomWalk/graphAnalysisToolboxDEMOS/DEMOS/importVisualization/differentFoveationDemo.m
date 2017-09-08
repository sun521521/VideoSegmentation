%Script used to demonstrate how to foveate on different parts of a single
%image
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
% Date - $Id: differentFoveationDemo.m,v 1.3 2003/08/21 17:46:03 lgrady Exp $
%========================================================================%

%Load image to import
img=im2double(imread('./../images/eslab0043.jpg'));
[X Y Z]=size(img);

%Load saved files
load ./../../SAVEDATA/animalVision/pigeon6400_256.mat

%First foveation
fov1=[200,300];

%Import image
vals1=importimg(imgGraph,img,fov1);

%First foveation
fov2=[500,200];

%Import image
vals2=importimg(imgGraph,img,fov2);


%Display
figure
subplot(2,2,1)
imagesc(img)
colormap(gray)
axis equal
axis tight
hold on
plot(fov1(1),fov1(2),'rx','MarkerSize',40,'LineWidth',5)
plot(fov2(1),fov2(2),'g+','MarkerSize',40,'LineWidth',5)
hold off
title('Original: ESLab0043')

subplot(2,2,2)
gplot(adjacency(edges),points,'k')
axis equal
axis tight
axis off
title('Pigeon structure')

subplot(2,2,3)
showvoronoi(vals1,voronoiStruct)
title('Foveation #1: Red')

subplot(2,2,4)
showvoronoi(vals2,voronoiStruct)
title('Foveation #2: Green')
