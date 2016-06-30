function slit_scan()

clc; clear; close all; imaqreset;

% To specify the number of images to be taken as the slit sweeps over the
% surface of the object.
prompt = {'Enter the number of images to be taken:'};
dlg_title = 'Input';
num_lines = 1;
answer = inputdlg(prompt,dlg_title,num_lines);
if isempty(answer)
    return;
end
num = str2double(answer{1});

% Connect to cameras
v1 = imaq.VideoDevice('pointgrey',1);
v2 = imaq.VideoDevice('pointgrey',2);
release(v1); release(v2);
v1.VideoFormat = 'F7_RGB_1288x964_Mode0';
v2.VideoFormat = 'F7_RGB_1288x964_Mode0';

% v1 = videoinput('pointgrey', 1, 'F7_RGB_1288x964_Mode0'); % Left
% v2 = videoinput('pointgrey', 2, 'F7_RGB_1288x964_Mode0'); % Right
% v1.ReturnedColorSpace = 'rgb';
% v2.ReturnedColorSpace = 'rgb'; 
% src = getselectedsource(v1);
% src2 = getselectedsource(v2);
% src.WhiteBalanceRBMode = 'Off';
% src2.WhiteBalanceRBMode = 'Off';
% 
% promptMessage = sprintf('Do you want to see the preview of the cameras?');
% titleBarCaption = '';
% button = questdlg(promptMessage, titleBarCaption, 'Yes', 'No', 'Yes');
% if strcmpi(button, 'Yes')
% 	show_preview(v1,v2);
% end
pause(0.75);

% Creating folders for the images.
disp('Creating folders');
mkdir('Recons_Images')
f = get(0,'ScreenSize');
% Creating an object with it's dimensions same as the dimensions of the
% screen which will be projected on the surface of the object.
im = zeros(f(4),f(3),3);
l = (f(4)) / num;
im(1,:,2) = 1;
k = 0;

% Moving the slit from top to bottom at equal 
for i = 1:ceil(l):f(4)
    if i ~= 1
        im(1:i,:,2) = 0;
    end
    im(i,:,2) = 1;
%     im(:,:,2) = circshift(im(:,:,2),ceil(l));
    k = k + 1;
    im1(k,:) = {im};
end

disp('Press enter to start taking the images after a blank screen appears');
pause(2);
% Adjusting the size and position of the figure handle
hFig = figure('Menubar','none', 'Units','normalized', 'Position',[0 0 1 1]);
set(hFig, 'Units','pixels')    
p = get(hFig, 'Position');
set(hFig, 'Position', [f(3)+1 31 f(3) f(4)]);
img = im1{1};
fpos = get(hFig,'Position');
axOffset = (fpos(3:4)-[size(img,2) size(img,1)])/2;
ha = axes('Parent',hFig,'Units','pixels','Position',[axOffset size(img,2) size(img,1)]);
imshow(im1{1},'Parent',ha);
pause;

% Capturing images as the slit is moving
for i = 1 : length(im1)
    imshow(im1{i}, 'Parent', ha);
    [im_l, im_r] = cam_images(v1, v2);
    iml(i,:) = {im_l};
    imr(i,:) = {im_r};
    clear im_l; clear im_r;
    pause(0.001);
end
pause(0.75); close all

% Uncomment the below to save the images

% disp('Saving the images');
% for num = 1 : length(im1)
%     fn1 = sprintf('cam--1-%d.tiff', num); % Left
%     fn2 = sprintf('cam--0-%d.tiff', num); % Right
%     file1 = fullfile('.\Recons_Images\',fn1);
%     file2 = fullfile('.\Recons_Images\',fn2);
%     imwrite(im2double(iml{num}), file1); 
%     imwrite(im2double(imr{num}), file2);
% end
disp('Done!');

%% Reconstruction
disp('Reconstrucion');

base_folder = 'C:\Users\croma\Documents\DivyaASI';
plyfile = 'plyfile.ply';
step = 1;
start = 20;
final = 40;
% Calibration
load('C:\Users\croma\Documents\DivyaASI\calibrationSession3.mat');
stereoParams = calibrationSession.CameraParameters;
% calculating F matrix
F = stereoParams.FundamentalMatrix;
eyeRecons(F, start, final, base_folder, iml, imr, plyfile, step, stereoParams);
disp('Reconstruction done, please check the PLY file');