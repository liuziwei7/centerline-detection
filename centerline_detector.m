clear; clc;

addpath(genpath('./lib/'));

% Set directories
dir_data = './data/';
dir_results = './results/'; mkdir(dir_results);
file_lines = [dir_results, 'lines_img.mat'];

% Set hyper-parameters
num_img = 1;
num_lines_per_img = 2;
border_crop = 5;
size_filter = 11;
flag_visualize = true;

% Initialization
lines_img = zeros(2, 4, num_img, 'single'); % store parameters (source and ending points) of detected lines

for id_img = 1:num_img

	I = imread([dir_data, 'mono_', num2str(id_img), '.png']);
	I_cropped = I(border_crop + 1:end - border_crop, border_crop + 1:end - border_crop, :); % crop out borders for noise suppression
	I_gray = rgb2gray(I_cropped);
	I_smoothing = medfilt2(I_gray, [size_filter, size_filter]);

	lineSegments = EDPFLines(I_smoothing);
	num_lines = size(lineSegments, 1);

	mat_len_line = zeros(1, num_lines);

	for id_line = 1:num_lines
		mat_len_line(id_line) = norm([lineSegments(id_line).sx, lineSegments(id_line).sy] - [lineSegments(id_line).ex, lineSegments(id_line).ey]);
	end

	[~, indices_line] = sort(mat_len_line, 'descend'); % sort lines by line length

	I_lines = I;

	for id_line_img = 1:num_lines_per_img
		
		idx_line = indices_line(id_line_img);
		
		% Compensate for the border cropping
		x1 = border_crop + lineSegments(idx_line).sx;
		y1 = border_crop + lineSegments(idx_line).sy;
		x2 = border_crop + lineSegments(idx_line).ex;
		y2 = border_crop + lineSegments(idx_line).ey;

        lines_img(id_line_img, :, id_img) = [x1, x2, y1, y2]';
        I_lines = insertShape(I_lines, 'Line', [x1, y1, x2, y2], 'Color', 'green');

	end

	if flag_visualize
		figure(1);
		imshow(I_lines);
	end

	imwrite(I_lines, [dir_results, 'mono_', num2str(id_img), '_lines.png']);

	disp(['Processing Img ', num2str(id_img), '...']);

end

% Save results
save(file_lines, 'lines_img', '-v7.3');
