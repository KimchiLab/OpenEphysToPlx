function OpenEphysAdcToDiscHeadFixMatlab(dir_name)

%% Check to see if files already exist
file_mask = 'DiscHeadFixADC.mat';
file_temp = dir(file_mask);
if ~isempty(file_temp)
    fprintf('%s already exists for %s\n', file_mask, dir_name);
    return;
end

%% Identify (analog) channel data: analog/behavioral events
files = OpenEphysInterruptedFiles(dir_name, 'ADC');

%% Load and Process data by channels
fprintf('Loading ADC data\n');
for i_ch = 1:numel(files)
    filename = files(i_ch).name;
    fprintf('%s (%d of %d): ', filename, i_ch, numel(files));

    % Load data for a given channel from the file
    all_header(i_ch) = load_open_ephys_header(filename); % Assume all have same info
    if i_ch == 1
        [all_data, timestamps, info] = load_open_ephys_data_faster(filename, 'unscaledInt16');
        all_data(:, 2:numel(files)) = NaN;
    else
        all_data(:, i_ch) = load_open_ephys_data_faster(filename, 'unscaledInt16');
    end
    fprintf('\n');
end

%% Convert from analog data to thresholded "digital" data
Fs = all_header(1).sampleRate;
bit_val = all_header(1).bitVolts;
all_data = double(all_data) * bit_val;
volt_thresh = 3; % 4 works for analog behavioral inputs, but not for rotary encoder data, which needs a lower value
all_data = all_data > volt_thresh;

%% Parse digital event data -> timestamps: depends on knowing events
event_names = {'StimGo', 'StimOther', 'Lick', 'Reinforcer', 'Trial', 'Opto'};
sec_dur = [0.2 0.2 0.01 0.02 1 2e-3]; % Min duration of events/trials
sec_between = [1 1 0.05 1 0.4 1]; % Min time between events/trials
% These events are all returned in terms of bins, not timestamps
[trial_data, beh_data] = DiscHeadFixBehMaskToTrials(all_data(:, 1:numel(event_names)), sec_dur, Fs, event_names, sec_between);

%% Parse treadmill: rotary encoder data: depends on knowing rotary encoder channels
idx_a = size(all_data, 2) - 1; % Second to last channel of analog inputs
idx_b = size(all_data, 2); % Last channel of analog inputs
rot = all_data(:, idx_a) & all_data(:, idx_b);
rot = double(rot); % Convert from logical to double for following indexing (could be int)
rot(rot == 1) = 2; % Change true to intermediate position = 2
rot(all_data(:, idx_a) & ~all_data(:, idx_b)) = 1; % One up, one down part of quadrature "chain"
rot(~all_data(:, idx_a) & all_data(:, idx_b)) = 3; % One up, one down part of quadrature "chain"
vel = diff([rot(1); rot]); % convert to velocity
vel(vel == -3) = 1; % Address wrap around problem
vel(vel == 3) = -1; % Address wrap around problem
pos = cumsum(vel); % convert to position

%% Save data
clear all_data
file_save = 'DiscHeadFixADC';
fprintf('Saving %s... ', file_save);
save(file_save);
fprintf('Done\n');

