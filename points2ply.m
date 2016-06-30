function points2ply(PLYfilename, coordinate, rgb, normals)
% coordinate is 3 * n single matrix for n points
% rgb        is 3 * n uint8  matrix for n points range [0, 255]


rgb = uint8(rgb);

file = fopen(PLYfilename,'w');
fprintf (file, 'ply\n');
fprintf (file, 'format ascii 1.0\n');
fprintf (file, 'element vertex %d\n', size(coordinate,2));
fprintf (file, 'property float x\n');
fprintf (file, 'property float y\n');
fprintf (file, 'property float z\n');
if exist('normals','var') && ~isempty(normals)
    fprintf (file, 'property float nx\n');
    fprintf (file, 'property float ny\n');
    fprintf (file, 'property float nz\n');
end
% if exist('rgb','var') && ~isempty(rgb)
fprintf (file, 'property uint8 red\n');
fprintf (file, 'property uint8 green\n');
fprintf (file, 'property uint8 blue\n');
% end
fprintf (file, 'end_header\n');

data1 = [coordinate; double(rgb)];
fprintf (file, '%d %d %d %d %d %d\n' ,data1);
fclose(file);

end