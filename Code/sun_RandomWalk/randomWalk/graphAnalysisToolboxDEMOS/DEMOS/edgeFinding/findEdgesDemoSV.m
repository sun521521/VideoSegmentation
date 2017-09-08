%Script used to demo edge finding on space-variant graphs
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
% Date - $Id: findEdgesDemoSV.m,v 1.4 2003/08/21 17:46:02 lgrady Exp $
%========================================================================%

%Parameters
valsScale=10;
geomScale=3;
iterations=15;

%Load image
img=im2double(imread('./../images/eslab0032.jpg'));
img=imresize(img,[256,320]); %Resize to a more manageable size
[X Y Z]=size(img);

%Load cheetah data
load ./../../SAVEDATA/animalVision/labrador6400_256.mat
N=size(points,1);

%Import image to graph
vals=importimg(imgGraph,img);

%Anisotropic blur via neighborhood averaging to even out noise
weights=makeweights(edges,vals,valsScale);
L=laplacian(edges,weights);
blurVals=diffusion(L,vals,iterations);

%Perform gradient threshholding edge detection
%Use weights to compensate for the less correlated distant pixels
weights=makeweights(edges,[],0,points,geomScale); 
edgeNodes1=findedges(edges,blurVals,0,weights);
edgeVals1=zeros(N,1);
edgeVals1(edgeNodes1)=1;

%Perform Laplacian threshholding edge detection
edgeNodes2=findedges(edges,blurVals,1,weights);
edgeVals2=zeros(N,1);
edgeVals2(edgeNodes2)=1;


%Display
figure
subplot(3,2,1)
imagesc(img)
axis equal
axis tight
axis off
title('Original image: ESLab0032.jpg')

subplot(3,2,2)
gplot(adjacency(edges),points,'k')
axis equal
axis tight
axis off
title('Labrador structure')

subplot(3,2,3)
showvoronoi(vals, voronoiStruct)
title('Original: eslab0032')

subplot(3,2,4)
showvoronoi(blurVals, voronoiStruct)
title('Blurred image')

subplot(3,2,5)
showvoronoi(edgeVals1, voronoiStruct)
title('Edges: Gradient threshholding')

subplot(3,2,6)
showvoronoi(edgeVals2, voronoiStruct)
title('Edges: Laplacian threshholding')
