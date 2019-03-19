% function OpenEphysToCommonRef(dirname)
% 
% Process openEphys continuous neural data channels to 
% subtract out a Common Average Reference
% CAR is calculated by electrode arrays: assuming 16ch arrays for now
%
% This function will run faster on local data than on data on the server
%
% Ref choices: Currently using median. Can use mean or median among channels, for examples
% Average/Mean: Mem and Math easier than for median
% Median: More resistant to outliers
% https://github.com/cortex-lab/spikes/blob/master/preprocessing/applyCARtoDat.m
%
% Note: What to do about dirs with multiple sessions/multiple underscores?

function OpenEphysToCommonRef(dirname)

%% Identify (analog) channel data: wideband neurophys
cd(dirname);
files = dir('*_CH*.continuous');
[~, sort_idx] = sort_nat({files.name}); % Since saved as 1..9, 10..16
files = files(sort_idx);

% %% Ignore discontinuous recording files: flagged with _n, e.g. 100_CH10_2.continuous
mask_regexp = cellfun(@isempty, regexp({files.name}, '^\d+_CH\d+_\d+'));
if sum(~mask_regexp)
    fprintf('Interrupted files present.\n');
end
files = files(mask_regexp);

%% Identify banks of 16 channels/presumed arrays
ch = nan(numel(files), 1);
for i_f = 1:numel(files)
    ch_temp = regexp(files(i_f).name, '_CH([0-9]{1,2}).', 'tokens', 'once');
    ch(i_f) = str2double(ch_temp{1});
end
num_ch = numel(ch);
num_ch_per_array = 16; % See if the are multiples of 16 channels/arrays, otherwise default to 8
if num_ch < num_ch_per_array || mod(numel(ch), num_ch_per_array)
    num_ch_per_array = 8;
end
idx_array = floor((ch-1)/num_ch_per_array) + 1;
[name_array, ~, hash_array] = unique(idx_array);
num_array = max(hash_array);

%% Load and Process data by array and then by channels
% Load & Process
fprintf('Will process %d channel files split into %d arrays of %d wires.\n', numel(files), num_array, num_ch_per_array);

tic;
for i_array = 1:num_array
    idx_ch = find(hash_array == i_array);
    fprintf('Array %d of %d:\n', i_array, num_array);
    
    for i_ch = 1:numel(idx_ch)
        filename = files(idx_ch(i_ch)).name;
%         fprintf('%s: ', filename);

        % Load data for a given channel from the file
        all_header(i_ch) = load_open_ephys_header(filename); % Assume all have same info
        if i_ch == 1
            all_data = load_open_ephys_data_faster(filename, 'unscaledInt16');
            all_data(:, 2:numel(idx_ch)) = NaN;
        else
            all_data(:, i_ch) = load_open_ephys_data_faster(filename, 'unscaledInt16');
        end

        % If using mean: can add to CAR and dispose of original data to save memory
    %     if i_ch == 1
    %         car = data;
    %     else
    %         car = car + data;
    %     end

%         TimeUpdate(i_ch, numel(idx_ch));
    end
    
    % Calculate common ref
%     tic;
    % "Zero" out each channel first: subtract median of each channel
    all_data = bsxfun(@minus, all_data, median(all_data,1)); % subtract median of each channel
    % Find median trace across all channels
    ref = median(all_data,2);
    % Subtract median trace from all channels
    all_data = bsxfun(@minus, all_data, ref); % subtract median of each time point
%     fprintf('Time for median: %.3f sec\n', toc); % Takes ~30 sec for 1hr recording x 16 ch array
    
    % Save data for each channel: Not strictly necessary if willing to load again later
    fprintf('Saving data - CARef for each channel:\n');
%     tic;
    for i_ch = 1:numel(idx_ch)
        file_ch = sprintf('CH%02d-Ref', ch(idx_ch(i_ch)));
        data = all_data(:, i_ch);
        header = all_header(i_ch);
        save(file_ch, 'data', 'header', '-v7.3');
%         TimeUpdate(i_ch, numel(idx_ch));
    end
%     fprintf('Time for saving data: %.3f sec\n', toc);

    % Save Common Ref
%     tic;
    header = all_header(1);
    file_ref = sprintf('CommonRef-%d', i_array);
    save(file_ref, 'ref', 'header', '-v7.3');
%     fprintf('Time for saving common ref: %.3f sec\n', toc);
end

fprintf('Done with all Common Ref\n\n');
