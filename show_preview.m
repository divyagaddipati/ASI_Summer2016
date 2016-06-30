function show_preview()
% To display the preview of the cameras

vid1 = videoinput('pointgrey', 1, 'F7_RGB_1288x964_Mode0'); % Left
vid2 = videoinput('pointgrey', 2, 'F7_RGB_1288x964_Mode0'); % Right
vid1.ReturnedColorSpace = 'rgb';
vid2.ReturnedColorSpace = 'rgb';
src = getselectedsource(vid1);
src2 = getselectedsource(vid2);
src.WhiteBalanceRBMode = 'Off';
src2.WhiteBalanceRBMode = 'Off';
vid1.FramesPerTrigger = 1;
vid2.FramesPerTrigger = 1;
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

end