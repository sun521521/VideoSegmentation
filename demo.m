% Script that gives a demo of the Fast Video Segment algorithm
%
%    Copyright (C) 2013  Anestis Papazoglou
%
%    You can redistribute and/or modify this software for non-commercial use
%    under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%    For commercial use, contact the author for licensing options.
%
%    Contact: a.papazoglou@sms.ed.ac.uk
clc; clear;
addpath( genpath( '.' ) );

% mfilename(): 返回正在执行的m文件的名字，不带扩展名
% [PATHSTR,NAME,EXT] = fileparts(FILE)
foldername = fileparts( mfilename( 'fullpath' ) );
name = importdata(fullfile( foldername, 'val.txt' ));
% The folder where the frames are stored in. Frames should be .jpg files
% and their names should be 8-digit sequential numbers (e.g. 00000001.jpg,
% 00000002.jpg etc)
for nameId = 1:length(name)
    fprintf('\n\n#processing the video: %s......\n', name{nameId});
    
    options.infolder = fullfile( foldername, 'Data', 'inputs', name{nameId} );
    
    options.results = fullfile( foldername, 'Data', 'results', name{nameId} );
    
    % The folder where all the outputs will be stored.
    options.outfolder = fullfile( foldername, 'Data', 'outputs', name{nameId} );
    
    % The optical flow method to be used. Valid names are:
    %   broxPAMI2011:     CPU-based optical flow.
    %   sundaramECCV2010: GPU-based optical flow. Requires CUDA 5.0
    options.flowmethod = 'broxPAMI2011';
    
    % The superpixel oversegmentation method to be used. Valid names are:
    %   Turbopixels
    %   SLIC
    options.superpixels = 'SLIC';
    
    % Create videos of the final segmentation and intermediate results?
    % We recommend turning this option to false for your actual dataset, as
    % rendering the video output is relatively computationally expensive.
    options.visualise = true;
    
    % Print status messages on screen
    options.vocal = true;
    
    % options.ranges:
    %   A matlab array of length S+1, containing the number for the
    %   first frame of each shot (where S is the total count of shots
    %   inside the options.infolder).
    %   The last element of the array should be equal to the total
    %   number of frames + 1.
    frames = dir([options.infolder '\*.jpg']);
    options.ranges = [ 1, min(length(frames), 32)];
    
    % options.positiveRanges:
    %		A matlab array containing the shots to be processed
    options.positiveRanges = [ 1 ];
    
    % If the frames are larger than options.maxedge in either height or width, they
    % will be resized to fit a (maxedge x maxedge) window. This greatly decreases
    % the optical flow computation cost, without (typically) degrading the
    % segmentation accuracy too much. If resizing the frame is not desirable, set
    % options.maxedge = inf
    options.maxedge = 400;
    
    % Use default params. For specific value info check inside the function
    params = getDefaultParams();   % 结构数组
    
    % Create folder to save the segmentation
    segmfolder = fullfile( options.outfolder, 'segmentations', 'VideoRapidSegment' );
    if( ~exist( segmfolder, 'dir' ) ), mkdir( segmfolder ), end;
    
    for( shot = options.positiveRanges )
        
        
        %     sunflow = loadFlow( options, shot );   % data.flow为cell: 1 x 13.  data.flow{1}(:, :, 2)为 u   int
        %     if( isempty( sunflow ) )
        %         sunflow = computeOpticalFlow( options, shot );
        %         data.flow = sunflow(1:end-1);
        %     end
        %     data.flow = sunflow(1:end-1);
        
        % Load optical flow (or compute if file is not found)
        data.flow = loadFlow( options, shot ); % data.flow为cell: 1 x 13.  data.flow{1}(:, :, 2)为 u   int
        if( isempty( data.flow ) )
            data.flow = computeOpticalFlow( options, shot );
        end
        
        
        
        % Load superpixels (or compute if not found)
        data.superpixels = loadSuperpixels( options, shot );   % data.superpixels： 14 x 1 cell
        if( isempty( data.superpixels ) )
            data.superpixels = computeSuperpixels( options, shot );
        end
        
        % Cache all frames in memory
        data.imgs = readAllFrames( options, shot );  % data.imgs： 14 x 1 cell
        
        data.id = shot;
        segmentation = videoRapidSegment( options, params, data );
        
%         % Save output
%         filename = fullfile( segmfolder, sprintf( 'segmentationShot%d.mat', shot ) );
%         save( filename, 'segmentation', '-v7.3' );
%         
    end
    
end
  rmpath( genpath( '.' ) );