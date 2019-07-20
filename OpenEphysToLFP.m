function OpenEphysToLFP(dir_name)

% dir_name = [dirDropboxKimchiLab '\Research\TyeLab\Data\DataEPhys\TonyChAT\4646_2018-12-21_14-01-27_Laser4_BF'];

if nargin < 1
    dir_name = pwd;
end

%% Check to see if files already exist
file_lfp = dir('*-LFP.mat');
if ~isempty(file_lfp)
    fprintf('LFP file already exists for %s\n', dir_name);
    return;
end

%% Identify (analog) channel data: wideband neurophys
files = OpenEphysInterruptedFiles(dir_name, 'CH');

%% Load and Process data by channels
Fs_target = 1e3;
data.num_ch_analog = numel(files);
data.ch = nan(data.num_ch_analog, 1);

for i_file = 1:numel(files)
    filename = files(i_file).name;
    fprintf('%s (%d of %d, started processing at %s)\n', filename, i_file, numel(files), DateTimestamp);
    [temp_data, timestamps, info] = load_open_ephys_data_faster(filename);
    
    data.ch(i_file) = str2double(info.header.channel(3:end));
    Fs = info.header.sampleRate;
    Fs_ratio = Fs / Fs_target; % To downsample, e.g. from 30k to 1k
    data.analog(i_file, :) = decimate(temp_data, Fs_ratio);
    
    if i_file == 1
        data.Fs_orig = Fs;
        data.Fs = Fs_target;
        data.ts = timestamps(round(1:Fs_ratio:end)); % Timestamps are already in units of sec
        if numel(data.ts) ~= size(data.analog, 2)
            fprintf('Timestamp / Data mistmatch on %s\\%s\n', dir_name, filename);
        end
        data.analog(data.num_ch_analog, 1) = NaN;
    end
end


%% Calculate spectrograms
[data.f, data.t, data.p] = OpBoxPhys_Spectrograms(data);

%% Save data
idx = strfind(dir_name, '\');
if ~isempty(idx)
    file_save = dir_name(idx(end)+1:end);
else
    file_save = dir_name;
end
file_save = [file_save '-LFP.mat'];
tic;
save(file_save, 'data', '-v7.3'); % Struct can not be saved to version older than 7.3, http://www.mathworks.com/help/matlab/ref/save.html
toc;


%% Display PSDs
clf;
temp_psdx = squeeze(mean(data.p, 2));
temp_db = SpecDb(temp_psdx);
colors = ColorGradientBlueDarkGrayRed(data.num_ch_analog);
crop_freq = [0 100];
mask_f = crop_freq(1) <= data.f & data.f <= crop_freq(end);
h = plot(data.f(mask_f), temp_db(mask_f, :));
for i_ch = 1:data.num_ch_analog
    set(h(i_ch), 'Color', colors(i_ch, :));
end
axis tight;
ylabel('Power (dB)');
xlabel('Freq (Hz)');
TitleSuper(file_save);
ExportPNG(['PSD-' file_save(1:end-4)])


%% Display specgtrograms
clf;
num_rows = 4;
num_cols = 8;
boundaries = [0.08 0.98 0.1 0.9];
margins = [0.15 0.2];
grid_axes = AxesGrid(num_rows, num_cols, boundaries, margins)';
c_lim = [0 30];
font_size = 10;
for i_ch = 1:data.num_ch_analog
    axes(grid_axes(i_ch));
    crop_freq = [0 100];
    mask_f = crop_freq(1) <= data.f & data.f <= crop_freq(end);
    temp_db = SpecDb(squeeze(data.p(:, :, i_ch)));
    h = PlotSpecGram(data.t, data.f(mask_f), temp_db(mask_f, :));
    if i_ch <= (data.num_ch_analog - num_cols)
        xlabel('');
        set(gca, 'XTickLabel', '');
    end
    if mod(i_ch, num_cols) ~= 1
        ylabel('');
        set(gca, 'YTickLabel', '');
    end
    title(sprintf('Ch %d', i_ch));
    set(gca, 'FontSize', font_size);
end
AxesSharedCAxis(grid_axes, c_lim);
TitleSuper(file_save);
ExportPNG(['Spec-' file_save(1:end-4)])

