function eyeRecons(F, start, final, base_folder, iml, imr, plyfile, step, stereoParams)
% Author : Rajat Aggarwal
% This program reconstructs the corneal surface using slit scanner
% approach in a dense manner. It Triangulates the 2d correspondances found
% using epipolar geometry. After that it triangulates the 2D points and find 3D
% correspondances.
%
% This program takes argument from the calibration steps and outputs the
% PLY file of the pcd after removing noise and outliers. This approach
% works on the data captured using slit lamp directly.
%
%
% F             - 3x3 Fundamental matrix obtained after calibration
%
% P1            - 3x4 Projection matrix corresponding to Left camera image
%
% P2            - 3x4 Projection matrix corresponding to Right camera image
%
% start         - starting index of the image w.r.t the given path string
%
% final         - last index of the image w.r.t the given path string
%
% base_folder   - relative path string of the base folder which has images
%                 w.r.t the code
%
% image_folder  - path of the folder which has images and containes both side
%                 camera images
%
% plyfile       - output ply filename
%
% step          - This is the density factor for finding the matches. More
%                 the step value, more sparse the point cloud will be. For
%                 very dense pcd, step = 1.
%
% stereoParams -  object returned by the calibration function
%                 StereoCalibrate
%
% Example       - F = [ -8.0378112288216476e-09, 9.8638469080441357e-07, -3.2659799865052830e-04;
%                      9.5945384367348209e-07,  3.0047126723740279e-08, -4.7945429608010851e-03;
%                     -4.5636133507868682e-04, 3.4304219056990747e-03, 1. ];
%                 P1 = [ -1.2863874344918097e+03, 0., 5.3091156005859375e+02, 0.;
%                       0., -1.2863874344918097e+03, 3.3765068817138672e+02, 0.;
%                       0., 0., 1., 0. ];
%                 P2 = [ -1.2863874344918097e+03, 0., 5.3091156005859375e+02, 1.0565779905386473e+05;
%                       0., -1.2863874344918097e+03, 3.3765068817138672e+02, 0.;
%                       0., 0., 1., 0. ];
%                 start = 0;
%                 final = 49;
%                 base_folder = '../';
%                 image_folder = 'asi_dataset_24092015/dataset1_dhruvil';
%                 plyfile = 'calib_30_dhruvil.ply';
%                 step = 1;

% Initialisation of large arrays, for speeding up the code
correspondances =  zeros(1000000, 4);
colorArray = zeros(1000000,3);
num_corres = 1;
total_left = 0;
total_right = 0;
colorImgL = 1;

for i = start:final

    tic
    if(mod(i,1)==0)
        disp(strcat('Running file: ' ,int2str(i)));
    end
    
    % choose the correct threshold
    threshL = 0.2;
    threshR = 0.2;
    
    % read image and convert into grayscale
    % Pre-processing steps
    % For right camera image
    
    right = imr{i};
    right_img = right(:,:,2);  % Taking the green channel
%     To remove noise
%     rect = [10 15 40 40];
%     [J,~] = SRAD(right_img1,30,0.9,rect);
%     right_img = J;    
    right_img_bw = im2bw(im2double(right_img), threshR);
    
%     To reduce the obtained thresholded component to single pixel width
%     component
    img = imfill(right_img_bw, 'holes');
    img = im2double(img);
    bound_edger = double(zeros(size(img)));

    for k = 1 : size(img,1)
        if ~isnan(floor(mean(find(img(k,:)==1),2)))
            x = floor(mean(find(img(k,:)==1),2));
            bound_edger(k,x) = 1;
        end
    end
    right_img_bw = bound_edger;
    right_img = double(right_img_bw).*(right_img);    
    
%     For left camera image
    left = iml{i};
    colorImgL = colorImgL + left;    
    left_img = left(:,:,2);
    % To remove noise
    % rect = [10 15 40 40];
    % [J,~] = SRAD(left_img1,30,0.9,rect);
    % left_img = J;
    left_img_bw = im2bw(im2double(left_img), threshL);
%     To reduce the obtained thresholded component to single pixel width
%     component
    img = imfill(left_img_bw, 'holes');
    img = im2double(img);
    bound_edgel = double(zeros(size(img)));

    for k = 1 : size(img,1)
        if ~isnan(floor(mean(find(img(k,:)==1),2)))
            x = floor(mean(find(img(k,:)==1),2));
            bound_edgel(k,x) = 1;
        end
    end
    left_img_bw = bound_edgel;    
    left_img = double(left_img_bw).*(left_img);

    test_right_img = right;
    
    % add into total images
    total_left = total_left + left_img_bw;
    total_right = total_right + right_img_bw;
    
    % find the points which lie on slits
    [ left_points_row, left_points_col] = find(left_img_bw == 1);
    
    % shifts the points wrt the image center and x-y replaced
    left_points = [left_points_col left_points_row];
    
    if isempty(left_points)
        continue;
    end
    % find the epipolar lines in the right image corresponding to left points
    lines = epipolarLine(F,left_points);
    % find boundary points wrt lines
    boundary_points = (lineToBorderPoints(lines, size(right_img)));    
    
    % finding matches by maximising gaussian on epipolar line
    for j = 1: step: size(lines)
        [xc, yc, pixels] = improfile(right_img, boundary_points(j, [1,3])', boundary_points(j, [2,4])' );
        [px, index] = max(pixels);   
        if(px>0)
            correspondances(num_corres,:) = [left_points(j,1) left_points(j,2) xc(index(1)) yc(index(1))];
            test_right_img(round(yc(index(1))), round(xc(index(1))),:) = [255 0 0];
            
            colorArray(num_corres,:) = left(left_points(j,2), left_points(j,1),:);
            num_corres = num_corres + 1;
            if(mod(num_corres, 10000)==0)
                disp('Correspondances found till now: ');
                disp(num_corres);
            end
        end
    end
    toc
end

% % strip correspondances
correspondances = correspondances(1:num_corres-1,:);
matchedPoints1 = correspondances(:,1:2);
matchedPoints2 = correspondances(:,3:4);

x1 = [matchedPoints1 ones(length(matchedPoints1),1)];
x2 = [matchedPoints2 ones(length(matchedPoints2),1)];
K1 = stereoParams.CameraParameters1.IntrinsicMatrix;
K2 = stereoParams.CameraParameters2.IntrinsicMatrix;
xn1 = x1 * inv(K1); % Normalizing 
xn2 = x2 * inv(K2);

matchedPoints1 = xn1(:,1:2);
matchedPoints2 = xn2(:,1:2);
colorArray = colorArray(1:num_corres-1,:);

% Triangulatation of the correspondances
pt_cloud = triangulate(matchedPoints1, matchedPoints2, stereoParams);
% Write points in plyfile
% 1:3 index gives spatial location of the points
% 4:6 index gives RGB value of the points
points2ply(plyfile, pt_cloud(:,1:3)', colorArray(:, 1:3)');
