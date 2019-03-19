function [cmap, colors] = ColorGradientBlueGrayRed(num_colors)

% From Red-Yellow-Green-Cyan-Blue-Magenta
% Blue-Cyan-Green-Yellow-Red-Magenta

% num_colors = 15;

num_lines = 2;
num_pts(1:num_lines) = floor(num_colors/num_lines);
for i = 1:mod(num_colors, num_lines)
    num_pts(i) = num_pts(i) + 1;
end

gray = ColorPicker('gray');

cmap = [
%     linspace(0, (1-1/num_pts(1)), num_pts(1))', zeros(num_pts(1), 1), ones(num_pts(1),1)
%     ones(num_pts(2), 1), zeros(num_pts(2),1), linspace(1, 1/num_pts(2), num_pts(2))'


    linspace(0, gray(1), num_pts(1))', linspace(0, gray(1), num_pts(1))', linspace(1, gray(1), num_pts(1))'
    linspace(gray(1), 1, num_pts(2))', linspace(gray(1), 0, num_pts(2))', linspace(gray(1), 0, num_pts(2))'

%     linspace(0, (1-1/num_pts(1)), num_pts(1))', zeros(num_pts(1), 1), ones(num_pts(1),1)
%     ones(num_pts(2), 1), zeros(num_pts(2),1), linspace(1, 1/num_pts(2), num_pts(2))'
];

colors = mat2cell(cmap, ones(size(cmap, 1), 1), size(cmap, 2));
