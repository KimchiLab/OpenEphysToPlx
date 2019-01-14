% OpenEphysToPlexon_Script
%
% Script to go through multiple OpenEphys directories and convert files 
% to Plexon format for offline sorting
% 
% This calls 3 main functions:
% OpenEphysToCommonRef: Creates a Common Average Reference for denoising for each array
% OpenEphysRefToSpikesPlexon: Uses ref corrected channels to find spikes and creates a plexon format file for sorting
% OpenEphysAdcToMatlab: Converts OpenEphys ADC files to a matlab file with events and/or treadmill data
% 
% Planned updates: Put events in file for sorting or .nex file

clear all;

%% Identify Directories
% Specify a root path, within which this will try to process each subdirectory
dir_root = '\\kaytye.mit.edu\Share3\Tony\1 - NEW Recordings\Eyal ChAT Recordings';
cd(dir_root);

dirs = dir('464*');
dirs = dirs([dirs.isdir]);

for i_dir = 1:numel(dirs)
    dirname = [dir_root '\' dirs(i_dir).name];
    cd(dirname);
    plx_filename = [dirs(i_dir).name '.plx'];
    fprintf('%2d/%2d %s\n', i_dir, numel(dirs), dirname);
    if exist(plx_filename, 'file')
        fprintf('File %s already exists', plx_filename);
    else
        fclose all; % Have had errors with files open, some being left open?
        OpenEphysToCommonRef(dirname);
        OpenEphysRefToSpikesPlexon(dirname);
        OpenEphysAdcToMatlab(dirname);
%         OpenEphysPlxMatToNex(dirname);
    end
    fprintf('\n');
end
