function [spike_wf, spike_pos, spike_set] = PhysAnalogToSpikeWaveformsBins(data, Fs, bitVolts)

%% Settings
% Filter analog signal settings for spikes
freq_lo = 0.3e3;
freq_hi = 7e3;
notch_flag = true;

% Spike Threshold settings
thresh_sigma = 5; % Sigma threshold units rather than MAD. http://www.scholarpedia.org/article/Spike_sorting

% % Sampling frequency (inverse of ISI)
% Fs = round(1/median(diff(timestamps(1:1e3))));

% Define spike window (how much to clip before and after crossing threshold)
% Initial runs: -500:750ms: Extraneous info pre, not enough info post to complete fall of waveform
% Praneeth code: -500:1000ms: Unclear if these are the parameters used
% Chris run: -300:1000ms: Unclear if these are the parameters used
spike_set.ts_pre = -0.375e-3; % in ms
spike_set.ts_post = 1e-3; % in ms
min_isi = 0.5e-3; % minimum time between spikes
bin_isi = round(min_isi * Fs);

%% Filter data
% tic;
data_filt = FilterSpikes(data, Fs, freq_lo, freq_hi, notch_flag);
% toc; % Takes 21 sec on Eyal's computer for single channel

%% Zero signal to median
data_filt = data_filt - median(data_filt);

%% Calculate threshold
% tic;
mad = median(abs(data_filt)); % From Praneeth code ref R Quian-Quiroga book. 
sigma = mad / 0.6745; % conversion factor 
% [In a standard normal distribution, z = � 0.6745 will contain 50% of the area under curve]
% 1/0.6745 = 1.4826
% In other words, the expectation of 1.4826 times the MAD for large samples of normally distributed Xi is approximately equal to the population standard deviation.
% https://en.wikipedia.org/wiki/Median_absolute_deviation
% toc; % Takes 11 sec on Eyal's computer for single channel
%     thresh = sigma * thresh_sigma;
% Other options? http://gaidi.ca/weblog/extracting-spikes-from-neural-electrophysiology-in-matlab

% Extract spikes via Threshold (assuming negative deflections)
thresh = 0 - (sigma * thresh_sigma);

% Find threshold crossings
spike_thresh = data_filt < thresh;
spike_start = find(diff([false; spike_thresh]) > 0);
spike_end = find(diff([false; spike_thresh]) < 0);

%% Realign spikes to local minima?
spike_pos = nan(size(spike_start));
spike_min_win = nan(size(spike_start));
num_spikes = numel(spike_pos);
for i_spike = 1:num_spikes
    temp_spike = data_filt(spike_start(i_spike):spike_end(i_spike));
    [spike_min_win(i_spike), minIdx] = min(temp_spike);
    spike_pos(i_spike) = spike_start(i_spike) + minIdx - 1;
end

% Define spike bins
spike_set.num_pre = floor(spike_set.ts_pre * Fs);
spike_set.num_post = ceil(spike_set.ts_post * Fs);
idx_bins = spike_set.num_pre:spike_set.num_post;
spike_set.num_bins = numel(idx_bins);

% Discard spikes at the edges
spike_pos = spike_pos((0-spike_set.num_pre) < spike_pos & spike_pos < numel(data_filt) - spike_set.num_post);

% Extract spike waveforms: 
% Following line bsxfun will fail if no spikes
if 0 == numel(spike_pos)
    spike_wf = [];
    return;
end
idx_spike_wf = bsxfun(@plus, spike_pos, idx_bins);
spike_wf = data_filt(idx_spike_wf);
% Make sure correct orientation if only 1 spike found: NumSpikes x NumBins
if numel(spike_pos) == 1 && size(spike_wf, 1) > 1
    spike_wf = spike_wf';
end

% Automatic large artifact removal? Eliminate any point that swing up and down 1 mV
volt_cutoff = 2e3; % Units in uV, so 1e3 = 1mV
bit_cutoff = volt_cutoff / bitVolts;
max_val = max(spike_wf, [], 2);
min_val = min(spike_wf, [], 2);
amp = max_val - min_val;
mask_amp = amp < bit_cutoff;

spike_wf = spike_wf(mask_amp, :);
spike_pos = spike_pos(mask_amp, :);
% fprintf('Eliminated %d of %d (%.1f%%) waveforms with amp > %d uV\n', sum(~mask_amp), numel(mask_amp), mean(~mask_amp)*100, volt_cutoff);

% Only process crossings > some distance apart? At least 0.5ms apart--only capture larger waveform if within that time
% min_val = min(spike_wf, [], 2);
bin_zero = idx_bins == 0;
val_zero = spike_wf(:, bin_zero);
mask_close = diff([spike_pos; inf]) < bin_isi;
idx_close = find(mask_close);
mask_remove = false(size(mask_close));
for i_close = 1:numel(idx_close)
%     plot(spike_wf(idx_close(i_close)+(0:1), :)');
    if val_zero(idx_close(i_close)) < val_zero(idx_close(i_close)+1)
        mask_remove(idx_close(i_close)) = true;
    else
        mask_remove(idx_close(i_close)+1) = true;
    end
end

spike_wf = spike_wf(~mask_remove, :);
spike_pos = spike_pos(~mask_remove, :);
% fprintf('Eliminated %d of %d (%.1f%%) waveforms with with isi < %.3f ms\n', sum(mask_remove), numel(mask_remove), mean(mask_remove)*100, min_isi*1e3);
