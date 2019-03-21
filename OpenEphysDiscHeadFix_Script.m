% OpenEphysDiscHeadFix_Script
%
% Script to go through multiple OpenEphys directories and extra data
% to various formats, including Plexon format for offline sorting

clear all;
% clc;
clf;

%% Identify Directories
% Specify a root path, within which this will try to process each subdirectory
% dir_root = '\\kaytye.mit.edu\Share3\Tony\1 - NEW Recordings\Eyal ChAT Recordings';
% dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\4645';
% dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\4646';
dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\4648';
% dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\4649';
% dir_root = 'D:\DataEphys';
cd(dir_root);

dirs = dir('*');
dirs = dirs(3:end); % Skip . and .. on windows
dirs = dirs([dirs.isdir]);

tic;
for i_dir = 1:numel(dirs)
% for i_dir = 13:numel(dirs)
    dir_name = [dir_root '\' dirs(i_dir).name];
    cd(dir_name);
    fprintf('%2d/%2d %s\n', i_dir, numel(dirs), dir_name);
    OpenEphysDiscHeadFixPrep(dir_name);
    TimeUpdate(i_dir, numel(dirs));
    fprintf('\n');
end
