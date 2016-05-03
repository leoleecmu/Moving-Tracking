clc; clear all;

inputObj = VideoReader('../SAM_0562.MP4');
nFrames = inputObj.NumberOfFrames;

T = 255;
t = 10;
fr = rgb2gray(read(inputObj,1));
[sy,sx] = size(fr);
MHI = cell(1,nFrames);
MHI{1} = fr.* T;

for i=2:(nFrames-1)
    I = rgb2gray(read(inputObj,i));
    Ib = rgb2gray(read(inputObj,i-1));
    D = abs(I-Ib)>5;
    for y = 1:sy
        for x = 1:sx
            if (D(y,x) == 1)
                MHI{i}(y,x) = T;
            else
                A = [0 (MHI{i-1}(y,x)-1)];
                MHI{i}(y,x) = uint8(max(A));
            end
        end
    end
    figure(1)
    imshow(MHI{i});
end

% for i=2:(nFrames-1)
%     I = rgb2gray(read(inputObj,i));
%     Ib = im2bw(I);
%     for y = 1:sy
%         for x = 1:sx
%             if (Ib(y,x) == 1)
%                 A = [255 (MHI{i-1}(y,x)+1)];
%                 MHI{i}(y,x) = uint8(min(A));
%             else
%                 MHI{i}(y,x) = MHI{i-1}(y,x);
%             end
%         end
%     end
%     figure(1)
%     imshow(MHI{i});
% end