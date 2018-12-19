%% GridRowColFromNum
function [num_row, num_col] = GridRowColFromNum(num)

num_row = floor(num ^ 0.5);
num_col = ceil(num / num_row);
