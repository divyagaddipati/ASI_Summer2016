function [im1, im2] = cam_images(cam1, cam2)
% Capturing the images

im1 = step(cam1); % Left
im2 = step(cam2); % Right
end