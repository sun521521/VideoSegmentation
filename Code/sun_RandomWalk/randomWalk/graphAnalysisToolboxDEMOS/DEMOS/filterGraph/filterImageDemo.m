%Script used to demo the filtering operations for an image defined 
%on an arbitrary graph.
%
%
%5/13/03 - Leo Grady

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
% Date - $Id: filterImageDemo.m,v 1.3 2003/08/21 17:46:02 lgrady Exp $
%========================================================================%

%Parameters
iterations=120; %Number of iterations suggested in Taubin (see 
    %filtergraph.m for reference)

%Load sloth data
load ./../../SAVEDATA/animalVision/dolphin6400_256.mat
N=size(points,1);
    
%Load image
img=im2double(imread('./../images/eslab0059.jpg'));
img=imresize(img,[320,256]); %Resize to a more manageable size
img=rgb2gray(img);
[X Y Z]=size(img);

%Import image to graph
vals=importimg(imgGraph,img);

%Build adjacency matrix
W=adjacency(edges);

%Filter with lowpass mean filter
outValsAvg=filtergraph(W,vals,iterations/10,[],1);

%Filter with lowpass Taubin filter
outValsLow=filtergraph(W,vals,iterations,[.15 .3],1);

%Filter with highpass Taubin filter
outValsHigh=normalize(vals-outValsLow,vals);

%Display 
figure
subplot(3,2,1)
imagesc(img)
colormap(gray)
axis equal
axis tight
axis off
title('Original: ESLab0059')
subplot(3,2,2)
gplot(W,points,'k')
axis equal
axis tight
axis off
title('Bottlenosed Dolphin Structure')
subplot(3,2,3)
showvoronoi(vals,voronoiStruct);
title('Imported Image')
subplot(3,2,4)
showvoronoi(outValsAvg,voronoiStruct);
title('Mean filtered image')
subplot(3,2,5)
showvoronoi(outValsLow,voronoiStruct);
title('Taubin lowpass filtered image')
subplot(3,2,6)
showvoronoi(outValsHigh,voronoiStruct);
title('Taubin highpass filtered image')
