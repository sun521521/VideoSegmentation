%Script used to apply anisotropic interpolation to foveal image
%
%
%5/25/03 - Leo Grady

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
% Date - $Id: fovealAnisotropicDemo.m,v 1.3 2003/08/21 17:46:03 lgrady Exp $
%========================================================================%

%Load foveal mesh
load ./../../SAVEDATA/animalVision/macaque6400_256.mat
N=size(points,1);

%Read image
img=im2double(imread('./../images/lenna.gif'));
[X Y]=size(img);

%Initialization
center=[80 0];
radius=30;
scale=30;
distScale=0;

%Import image
valsOrig=normalize(importimg(imgGraph,img));
weights=makeweights(edges,valsOrig,scale,points,distScale);

%Cut out region
inCircle=find(((points(:,1)-center(1)).^2 + (points(:,2)-center(2)).^2) ...
    < radius^2);
vals=valsOrig;
vals(inCircle,:)=1;

%Solve interpolation problem
L=laplacian(edges,weights);
index=1:N;
index(inCircle)=[];
newVals=dirichletboundary(L,index,vals(index,:));

%Display original
figure
subplot(2,2,1)
showvoronoi(valsOrig,voronoiStruct);
title('Original Image')

%Display structure
W=adjacency(edges);
subplot(2,2,2)
gplot(W,points,'k')
axis equal
axis tight
axis off
title('Macaque foveal structure')

%Display cut region
subplot(2,2,3)
showvoronoi(vals,voronoiStruct);
hold on
indicator=sparse(N,1);
indicator(inCircle)=1;
neighs=W*indicator;
neighs(inCircle)=0;
circNeighs=find(neighs);
totalCirc=[inCircle;circNeighs];
Wtmp=W;
Wtmp(circNeighs,circNeighs)=0;
gplot(Wtmp(totalCirc,totalCirc),points(totalCirc,:),'k');
hold off
title('Image with removed values')

%Display interpolation
subplot(2,2,4)
showvoronoi(newVals,voronoiStruct);
title('Anisotropically interpolated values')
