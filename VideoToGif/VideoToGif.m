%{
Written By: Brandon Johns
Date Version Created: 2020-07-01
Date Last Edited: 2021-01-07
Purpose: write video file to gif
Status: functional
Referenced files: na           Version _, date

%%% PURPOSE %%%

%%% TODO %%%

%%% NOTES %%%
Matlab doen't do a very good job at gif compression and seems to not have any optional compression param

%}
close all
clear all
clc

% Input File
% Cut the video roughly to size first

filenameIn = 'test'; % Input file name without extension
fileExIn = 'mp4';  % Input file extension

filenameAppendOut = '_out';  % Output file name = filenameIn + filenameAppendOut

%****************************************************************
% Options
%********************************
% Trim gif
frameStart = 1; % Frame of video to start gif at, not including skipped frame (positive int)
maxFramesOut = 300; % Just setting to a large number for now (positive int)

% Edit frame rate
frameSkip = 1; % Number of frames to skip per out frame (0 or positive int)
speed = 1; % Speed up / slow down output by factor (positive decimal)

% Edit Frame
numColours = 64; % Very literally (positive int)
dimHOut = 400; % Hight in px (positive int)

%****************************************************************
% Mostly Automated
%********************************
% Read video
video = VideoReader(strcat(filenameIn,'.',fileExIn));
dimH = video.Height;
dimW = video.Width;
dimAR = dimW/dimH;

% Output file name
filenameOut = strcat(filenameIn,filenameAppendOut,'.gif');

% Output framerate & speed
frameRateOut = video.FrameRate/(1 + frameSkip);
interframeDelay = 1/(frameRateOut * speed);

maxPossibleFramesOut = floor((video.NumFrames - frameStart)/(1 + frameSkip)) + 1;
if maxPossibleFramesOut < maxFramesOut
    % Limit output by  length of video
    maxFramesOut = maxPossibleFramesOut;
    fprintf('Reached end of video. FramesOut = %d\n', maxFramesOut);
else
    warning('Did not reach end of video. Truncating at %d of %d', maxFramesOut, maxPossibleFramesOut)
end

% Play video frame by frame
currentFrameIn = 0;
nextFrameIn = frameStart;
for currentFrameOut = 1: maxFramesOut
    % Skip to next frame
    while currentFrameIn < nextFrameIn
        if hasFrame(video)
            % Read next frame
            frame = readFrame(video);
        else
            error('Ran out of frames')
        end
        currentFrameIn = currentFrameIn+1;
    end
    
    % Resize [height, width]
    frame = imresize(frame,[dimHOut round(dimHOut*dimAR)]);
    
    % Compress colours and dither
    [A,map] = rgb2ind(frame, numColours, 'nodither');
    %[A,map] = rgb2ind(frame, NumColours, 'dither'); % auto colourmap
    %[A,map] = rgb2ind(frame, [0,0,0;1,1,1], 'dither'); % specify colourmap
    %[A,map] = rgb2ind(frame, [0.2,0.2,0.2;.8,.8,.8], 'dither'); % specify colourmap
    
    % Write to file
    if currentFrameOut == 1
        imwrite(A,map, filenameOut,'gif', 'LoopCount',Inf, 'DelayTime',interframeDelay);
    else
        imwrite(A,map, filenameOut,'gif', 'WriteMode','append', 'DelayTime',interframeDelay);
    end
    
    % Prep for next loop
    nextFrameIn = nextFrameIn + 1 + frameSkip;
end


