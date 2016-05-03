%% Initialization
clc;
clear;

inputObj = VideoReader('../SAM_0562.mp4');
numberOfFrames = inputObj.numberOfFrames;
height = inputObj.Height;
width = inputObj.Width;

max_iter = 5;

%% Get rect from first frame 
firstFrame = read(inputObj, 1);
try
    sprintf('Please draw rectangle on image to specify the tracking area!');
    imshow(firstFrame);
    rect = getrect;
catch
    sprintf('Error when selecting tracking area!');
    return;
end
patch = imcrop(firstFrame, rect);
[m, n, ~] = size(patch);

%% Kernel Density Estimation
patchK = zeros(m, n);
sigmaM = (m/2)/3;
sigmaN = (n/2)/3;

for i = 1: m
    for j = 1: n
        patchK(i, j) = exp(-.5*((i-.5*m)^2/sigmaM^2+(j-.5*n)^2/sigmaN^2));
    end
end

[gx, gy] = gradient(-patchK);


[I,map] = rgb2ind(firstFrame,65536);
Lmap = length(map)+1;
patch= rgb2ind(patch,map);

q = density_estimation(patch,Lmap,patchK,m,n);

%% Mean-shift
f = zeros(1,(numberOfFrames-1)*max_iter);
f_indx = 1;
f_thresh = 0.16;
loss = 0;

outputVideo = VideoWriter('output.avi');

firstFrame = insertShape(firstFrame, 'Rectangle', rect, 'Color', 'green', 'LineWidth', 2);
for t=1:numberOfFrames-1
    frameTemp = rgb2ind(read(inputObj, t + 1), map);    
    [x,y,loss,f,f_indx] = MeanShift_Tracking(q,frameTemp,Lmap,height,width,f_thresh,...
        max_iter,rect(1,1),rect(1,2),rect(1,3),rect(1,4),patchK,gx,gy,f,f_indx,loss);
    % Check for target loss. If true, end the tracking
    if loss == 1
        break;
    else
        % Drawing the target location in the next frame
        frameInserted = insertShape(frameTemp, 'Rectangle', rect, 'Color', 'green', 'LineWidth', 2);
        writeVideo(outputVideo, frameInserted);
        % Next frame becomes current frame
        rect(1,1) = x;
        rect(1,2) = y;
    end
end
close(outputVideo);


