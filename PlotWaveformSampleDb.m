function grid_axes = PlotWaveformSampleDb(db)

%% Display sample waveforms
num_ch = numel(db);
boundaries = [0.1 0.95 0.1 0.95];
margins = [0.2 0.2];
clf;

all_ts = vertcat(db.spike_ts);
min_ts = min(all_ts);
max_ts = max(all_ts);
dur = max_ts - min_ts;

% [num_row, num_col] = GridRowColFromNum(num_ch);
% Assuming arrays are multiples of 8
if num_ch > 12
    num_col = 8;
else
    num_col = 4;
end
num_row = ceil(num_ch / num_col);

grid_axes = AxesGrid(num_row, num_col, boundaries, margins)';
for i_ch = 1:numel(db)
    axes(grid_axes(i_ch));
    PlotWaveformSample(db(i_ch).spike_wf, db(i_ch).spike_set);
    fr = numel(db(i_ch).spike_ts) / dur;
    title(sprintf('Ch%d = %.1f Hz', i_ch, fr));
    if 1 ~= mod(i_ch, num_col)
        set(gca, 'YTickLabel', []);
    end
    if i_ch <= (numel(grid_axes) - num_col)
        set(gca, 'XTickLabel', []);
    end
end
AxesSharedLimits(grid_axes);


