function h = PlotWaveformSample(spike_waveforms, Fs)

if nargin < 2
    Fs = 30e3;
end

% % previous cutoff evaluation moved to another function
% 
% if nargin < 3
%     % then no threshold passed in
%     threshold = [];
%     if nargin < 2
%         % then no other waveforms passed in
%         other_waveforms = [];
%     end
% end

line_width = 0.001;

[num_spikes, num_bins] = size(spike_waveforms);

max_wf = 1e3;
num_plot = min(max_wf, num_spikes);
idx_wf = round(linspace(1, num_spikes, num_plot));

% hold on;
% % make sure have something to plot?
% % for some reason, plot transposes waveforms when pull just one out
% % so transpose to plot matrix
% if ~isempty(other_waveforms)
% 	h = plot(other_waveforms');
% 	set(h, 'Color', gray, 'LineWidth', line_width/10);
% end
% 
% set(gca, 'XTick', [], 'YTick', []);
% max_wave = 2^11;
% min_wave = 0-max_wave;
% axis([-Inf Inf min_wave max_wave]);

% if ~isempty(threshold)
% 	h = line([1 size(spike_waveforms,2)], [threshold/100*max_wave threshold/100*max_wave]);
% 	set(h, 'LineStyle', '--', 'Color', 'k', 'LineWidth', 0.7);
% end
% 
% % plot a sample of unit waveforms
% % plot these second so that they are on top

%% Plot waveforms
ts = (0:num_bins-1) / Fs;
ts = ts * 1e3; % Convert from sec to ms
h = plot(ts, spike_waveforms(idx_wf, :)');
set(h, 'Color', ColorPicker('black'), 'LineWidth', line_width);

% gradient from cold to warm, e.g. blue to red
% colors = ColorGradientBMR(numel(h));
colors = ColorGradientBlueGrayRed(numel(h));

% Transparency only works in R2014b and later: setting 2015 as cutoff for speed
temp_ver = ver('MATLAB');
mask_ver = datenum(temp_ver.Date) >= datenum(2015,1,1);
trans = 0.15;

for i = 1:numel(h)
    if mask_ver
        set(h(i), 'Color', [colors(i, :) trans]); % Only works for R2014b and later
    else
        set(h(i), 'Color', colors(i, :));
    end
end
axis tight;
% xlabel('Time (ms)');
% ylable('Volt (uv)');

