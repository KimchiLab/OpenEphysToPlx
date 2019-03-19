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
clc;
clf;

%% Identify Directories
% Specify a root path, within which this will try to process each subdirectory
% dir_root = '\\kaytye.mit.edu\Share3\Tony\1 - NEW Recordings\Eyal ChAT Recordings';
dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\4645';
% dir_root = '\\kaytye-fs2.mit.edu\Share\Eyal\Data\DataEPhys\4649';
% dir_root = 'D:\DataEphys';
cd(dir_root);

% dirs = dir('464*');
dirs = dir('*');
dirs = dirs(3:end); % Skip . and .. on windows
dirs = dirs([dirs.isdir]);

tic;
% for i_dir = 1:numel(dirs)
for i_dir = 14:numel(dirs)
    dir_name = [dir_root '\' dirs(i_dir).name];
    cd(dir_name);
    fprintf('%2d/%2d %s\n', i_dir, numel(dirs), dir_name);
    
    plx_filename = [dirs(i_dir).name '.plx'];
    if exist(plx_filename, 'file')
        fprintf('File %s already exists\n', plx_filename);
    else
        fclose all; % Have had errors with files open, some being left open by utils?
        % Check if interrupted recordings are present: Skip files within function below for now, process as sets of different recordings in future
        OpenEphysToCommonRef(dir_name);
        OpenEphysRefToSpikesPlexon(dir_name); % This is based on referenced channels
        OpenEphysToLFP(dir_name); % Processes one channel at a time. Will be previously loaded, but simpler to do sequentially. This is not based on referenced channels
        try
            OpenEphysAdcToDiscHeadFixMatlab(dir_name); % This depends on knowing what the analog channels "mean", so specific to different protocols
        catch
            fprintf('Error with ADC conversion, due to corrupted data/noncontiguous/restart?\n');
        end
%         OpenEphysPlxMatToNex(dir_name); % This depends on a file already being sorted
    end
    fprintf('\n');
    TimeUpdate(i_dir, numel(dirs));
end
