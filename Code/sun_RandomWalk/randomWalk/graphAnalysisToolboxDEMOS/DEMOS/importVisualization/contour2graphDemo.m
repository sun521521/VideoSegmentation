%Script used to demonstrate the conversion of a contour image to a graph.
%
%Note: Due to the size of cheetahContour.bmp, this script takes some time
%to run (approximately 15 minutes on a 1.3GHz Athlon).
%
%
%5/29/03 - Leo Grady

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
% Date - $Id: contour2graphDemo.m,v 1.3 2003/08/21 17:29:30 lgrady Exp $
%========================================================================%

%Initialization
X=254;
Y=254;
samples=6400;

%Read contour for the cheetah ganglion cell distribution
img=im2double(imread('./../images/contours/cheetahContour.bmp')); 

%Produce pdf from image
imgPDF=contour2pdf(img);

%Sample from pdf and produce graph
[points edges]=pdf2graph(imgPDF,samples);

%Display
figure
subplot(1,3,1)
imagesc(img)
axis equal
axis tight
axis off
colormap(gray)
title('Cheetah ganglion isodensity topography')

subplot(1,3,2)
imagesc(1-imgPDF)
axis equal
axis tight
axis off
colormap(gray)
title('Interpolated probability density function')

subplot(1,3,3)
gplot(adjacency(edges),points,'k')
axis equal
axis tight
axis off
title('Sampled graph')
