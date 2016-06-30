clc; clear; close all;
imaqreset;

f = figure('Visible','on','Position',[438, 184, 450,350]);

uicontrol('Style','Text','String','Choose for which you want to capture the images:','FontSize',12,'Position',[105,200,250,100]);
uicontrol('Style','pushbutton','String','Calibration','Position',[100,135,100,50],...
    'Callback', 'capture_cali_images');
uicontrol('Style','pushbutton','String','Reconstruction','Position',[250,135,100,50]...
    ,'Callback', 'slit_scan');
