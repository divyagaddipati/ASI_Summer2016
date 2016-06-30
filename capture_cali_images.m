function capture_cali_images()
% Capture images during calibration

close all; clear; imaqreset;
% To specify the number of images to be taken
prompt = {'Enter the number of images to be taken:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
if isempty(answer)
    return;
end
num = str2double(answer{1});

% Connect to cameras
vid1 = videoinput('pointgrey', 1, 'F7_Mono16_1288x964_Mode0'); % Left
vid2 = videoinput('pointgrey', 2, 'F7_Mono16_1288x964_Mode0'); % Right
vid1.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;
vid1.ReturnedColorspace = 'rgb';
vid2.ReturnedColorspace = 'rgb';
vidRes1 = vid1.VideoResolution;    
nBands1 = vid1.NumberOfBands;
hImage1 = zeros(vidRes1(2), vidRes1(1), nBands1);
vidRes2 = vid2.VideoResolution;    
nBands2 = vid2.NumberOfBands;
hImage2 = zeros(vidRes2(2), vidRes2(1), nBands2);
subplot(1,2,1); h1 = subimage(hImage1);    
subplot(1,2,2); h2 = subimage(hImage2);
preview(vid1, h1); 
preview(vid2, h2); 

global k;
k=0;

uicontrol('String', 'Close', 'Position',[300 20 60 40], 'Callback', 'close(gcf)');
uicontrol('String', 'Capture', 'Position',[200 20 60 40], 'Callback', {@take_image, vid1, vid2}');

disp('Creating folders');
mkdir('Cali_Images')
mkdir('.\Cali_Images\Left')
mkdir('.\Cali_Images\Right')

for i = 1 : num+1
    if i ~= num+1
        if(mod(i,1)==0)
            disp(strcat('Click on "Capture" to get Image- ' ,int2str(i)));
        end
        waitforbuttonpress;
    end
    if i == num+1
        waitforbuttonpress;
        close(gcf);
    end
end
close all;
disp('Done!');

end