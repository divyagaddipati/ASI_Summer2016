function take_image(hObject, CallBack, cam1, cam2)

% This function is used during camera calibration to capture images from 
% left and right cameras.

global k;
k = k + 1;
a = k ;

im1 = getsnapshot(cam1); % Left camera
im2 = getsnapshot(cam2); % Right camera
fn1 = sprintf('cam--1-%d.tiff', a); % Left camera
fn2 = sprintf('cam--0-%d.tiff', a); % Right camera
file1 = fullfile('.\Cali_Images\Left\',fn1);
file2 = fullfile('.\Cali_Images\Right\',fn2);
imwrite(im1, file1); 
imwrite(im2, file2);

end