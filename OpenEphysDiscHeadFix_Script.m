% OpenEphysDiscHeadFix_Script
%
% Script to go through multiple OpenEphys directories and export data
% to various formats, including Plexon format for offline sorting

clear all;
% clc;
clf;

%% Identify Directories
% Specify a root path, within which this will try to process each subdirectory
dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\ChAT_BLA_PFC';
% dir_root = 'D:\DataEphys';
% dir_root = 'C:\temp';
cd(dir_root);

dirs = dir('*');
dirs = dirs([dirs.isdir]);
mask_dir = cellfun(@isempty, regexp({dirs.name}, '^\.')); % Skip . and .. on windows
dirs = dirs(mask_dir);

tic;
for i_dir = 1:numel(dirs)
    dir_name = [dir_root '\' dirs(i_dir).name];
    cd(dir_name);
    fprintf('%2d/%2d %s\n', i_dir, numel(dirs), dir_name);
    OpenEphysDiscHeadFixPrep(dir_name);
    TimeUpdate(i_dir, numel(dirs));
    fprintf('\n');
end
