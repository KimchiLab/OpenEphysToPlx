% OpenEphysDiscHeadFixPrep
%
% Script to go through multiple OpenEphys directories and extra data
% to various formats, including Plexon format for offline sorting
% 
% This calls 3 main functions:
% OpenEphysToCommonRef: Creates a Common Average Reference for denoising for each array
% OpenEphysRefToSpikesPlexon: Uses ref corrected channels to find spikes and creates a plexon format file for sorting
% OpenEphysToLFP: Convert wideband data to downsampled LFP data
% OpenEphysAdcToMatlab: Converts OpenEphys ADC files to a matlab file with events and/or treadmill data
% 
% Planned updates: Put events in file for sorting or .nex file

function OpenEphysDiscHeadFixPrep(dir_name)

cd(dir_name);
[a, b, c, d] = regexp(pwd, '\\([\w- ])*');
name_session = d{end}(2:end);
plx_filename = [name_session '.plx'];
% % Check if file already exists?
% if exist(plx_filename, 'file')
%     fprintf('File %s already exists\n', plx_filename);
% else
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
% end
