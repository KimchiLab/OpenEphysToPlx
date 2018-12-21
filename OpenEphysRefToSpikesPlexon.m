% function OpenEphysRefToSpikesPlexon(dirname)
%
% Take files that have already had the common ref removed and
% Filter each referenced channel and 
% Extract spikes to write a plexon file
% 
% This function will run faster on local data than on data on the server

function OpenEphysRefToSpikesPlexon(dirname)

%% Identify (analog) channel data: wideband neurophys
cd(dirname);
files = dir('CH*-Ref.mat');
[~, sort_idx] = sort({files.name}); % Saves as 0 leading, so don't need to sort_nat as in other functions
files = files(sort_idx);

%% Load and Process data by channels
% Prep structure
clear db;
db(numel(files)).ch = [];
db(numel(files)).spike_wf = [];
db(numel(files)).spike_ts = [];

% Load & Process
tic;
for i_file = 1:numel(files)

    filename = files(i_file).name;
    fprintf('%s (%d of %d, started processing at %s)\n', filename, i_file, numel(files), DateTimestamp);

    load(filename);
    db(i_file).header = header;
    db(i_file).ch = str2double(header.channel(3:end));
    Fs = header.sampleRate;
    bitVolts = header.bitVolts;
    
    [db(i_file).spike_wf, db(i_file).spike_ts] = PhysAnalogToSpikeWaveformsBins(data, Fs, bitVolts);
    db(i_file).spike_wf = db(i_file).spike_wf * bitVolts;
    db(i_file).spike_ts = db(i_file).spike_ts / Fs;
    TimeUpdate(i_file, numel(files));
    
    % Takes total 43 sec on Eyal's computer for single channel from 2hr recording on local drive
    % Takes total 157 sec on Eyal's computer for single channel from 3hr recording on server
end
fprintf('\n');

%% Save mat db
filename = 'DbWaveform';
save(filename, 'db', '-v7.3');

%% Plot waveform samples
grid_axes = PlotWaveformSampleDb(db);

%% Export plx file for Plexon Offline Sorter
% plx_filename = [filename(1:strfind(filename, '.')) 'plx'];
[a, b, c, d] = regexp(pwd, '\\([\w- ])*');
plx_filename = d{end}(2:end);
plx_filename = [plx_filename '.plx'];
fprintf('Saving %s: ',plx_filename);

% units = zeros(num_spikes, 1); % unsorted
% [num_spikes, num_bins] = size(spike_wf);
units = repmat({0}, numel(db), 1);

tic;
% nWritten = write_plx(plx_filename, ch, Fs, num_bins, num_spikes, ts, spike_wf, units); % Single Ch--Plexon SDK code
nWritten = pn_write_plx(plx_filename, [db.ch], Fs, {db.spike_ts}, {db.spike_wf}, units); % Multi Ch, modified by Praneeth Namburi
% nWritten = pn_write_plx(plx_filename, {db.ch}, Fs, {db.ts}, {db.spike_wf}); % Multi Ch, modified by Praneeth Namburi
toc; % 20 sec for single file on Eyal's computer to local drive for 600k spike file, 1 min for server

fprintf('\n');
