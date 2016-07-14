# ASI_Summer2016

GUI for capturing images using Point Grey cameras for 3D reconstruction of the anterior segment of the human eye.

The hardware consists of two cameras at an angle and a laser projector between the two.
Firstly the camera setup needs to be properly calibrated to obtained a good reconstruction.

The GUI consists of two parts:
- Capturing images of checkerboard for calibration.
- Capturing images of the moving slit for reconstruction.

Calibration
- Choose the 'Calibration' option in the GUI. 
- After capturing the images of the checkerboard for calibration, stereoCameraCalibrator tool is used to obtain the intrinsic and extrinsic parameters of the stereo setup.
- The input to the stereoCameraCalibrator tool are the image pairs and the accurate size of the checkerboard taken.
- The output is a mat file which contains all the parameters that are required for reconstruction.

Reconstruction
- Choose the 'Reconstruction' option in the GUI.
- The output is the 3D co-ordinates which is obtained in a ply file.
- MeshLab software is required to view the 3D surface.

Softwares required:
- MATLAB R2015
- MeshLab 
