%Script used to read in images of contours and produce graphs
%
%Note: Takes some time to process all species (e.g., a few hours)
%Included only to offer the procedure used to generate the space-variant
%graphs in the SAVEDATA directory
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
% Date - $Id: generateSVgraphsDemo.m,v 1.3 2003/08/21 19:56:44 lgrady Exp $
%========================================================================%

%Initialization
X=254; Y=254; %Dimensions of images to import
samples=6400; %Number of samples (nodes) to take from distribution
saveLocation='./../../SAVEDATA/animalVision/';
readLocation='./../images/contours/';

%Open list file
fptr = fopen(strcat(readLocation,'contourList.txt'),'r');

%Read current filename
stub = fscanf(fptr, '%s', 1);
stringLen=length(stub);

%If file not done, continue generating graphs
while ~strcmp('exit',stub)
    %Read image
    img=im2double(imread(strcat(readLocation,stub)));
    stub
    
    %Produce pdf from image
    img=contour2pdf(img);
    
    %Sample from pdf and produce graph
    [points,edges]=pdf2graph(img,samples);
    
    %Find filters for imputing graph and generate ImgGraph
    [imgGraph,points,edges]=findfilter(points,[X Y]);    
    
    %Find Voronoi structure
    voronoiStruct=voronoicells(points,1); 
        
    %Save graph for future use
    save(strcat(saveLocation,stub(1:(stringLen-9)),num2str(samples),'_',...
        num2str(max(X+2,Y+2))),'imgGraph','points','edges', ...
        'voronoiStruct')
    
    %Read current filename
    stub = fscanf(fptr, '%s', 1);
    stringLen=length(stub);
end

%Find macaque sampling
[imgGraph,points,edges,faces,voronoiStruct]= ...
    logz(floor(max(X+2,Y+2)/2),1,ceil(sqrt(samples)), ...
    ceil(sqrt(samples)));
save(strcat('macaque',num2str(samples),'_',...
        num2str(max(X,Y))),'imgGraph','points','edges','voronoiStruct')
