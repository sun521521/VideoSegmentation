%Script used to apply isotropic interpolation to foveal image
%
%
%5/22/03 - Leo Grady

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
% Date - $Id: fovealIsotropicDemo.m,v 1.3 2003/08/21 17:46:03 lgrady Exp $
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

%Import image
origVals=normalize(importimg(imgGraph,img));
N=size(points,1);

%Cut out region
inCircle=find(((points(:,1)-center(1)).^2 + (points(:,2)-center(2)).^2) ...
    < radius^2);
vals=origVals;
vals(inCircle,:)=max(origVals);

%Solve interpolation problem
L=laplacian(edges);
index=1:N;
index(inCircle)=[];
newVals=dirichletboundary(L,index,vals(index,:));

%Display structure
figure
W=adjacency(edges);
subplot(2,2,1)
showvoronoi(origVals,voronoiStruct);
title('Imported Image')

subplot(2,2,2)
gplot(W,points,'k')
axis equal
axis tight
axis off
title('Macaque structure')

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
title('Missing Region')

subplot(2,2,4)
showvoronoi(newVals,voronoiStruct)
title('Isotropic Interpolation')
