% function OpenEphysPlxMatToNex(dirname)
%
% Takes data previously converted into a plx file for sorting and matlab matrices for events
% and exports a .nex file

function OpenEphysPlxMatToNex(dirname)

cd(dirname);

%% Load ADC data: from prior preparation of OpenEphys -> PLX scripts
file_adc = 'DataADC.mat';
if ~exist(file_adc, 'file') || isempty(dir('*.plx'))
    fprintf('Files missing: ADC or .plx\n');
else
    load(file_adc);
end

%% Prep header
% clear nex; % Most functions below append data, clear here is for debugging purposes
nex.version = 101;
nex.comment = '';
nex.freq = Fs;
nex.tbeg = 0;
nex.tend = 0;

%% Add events
if exist('beh_data', 'var')
    event_names = fieldnames(beh_data);
    for i_event = 1:numel(event_names)
        if ~isempty(beh_data.(event_names{i_event}))
            % Convert from bins to timestamps using Fs
            nex = nexAddEvent(nex, beh_data.(event_names{i_event}) / Fs, event_names{i_event});
        end
    end
end

%% Add continuous data, e.g. treadmill (LFPs in future?)
if exist('pos', 'var')
    nex = nexAddContinuous(nex, 0, Fs, pos, 'TreadmillPosition');
end
if exist('vel', 'var')
    nex = nexAddContinuous(nex, 0, Fs, vel, 'TreadmillVelocity');
end


%% Load plx sorted data in order to add event timestamps
% Utils from Chronux via https://github.com/jsiegle/chronux and/or Prior plexon utilities
% e.g. plx_ts or plx_info from https://plexon.com/wp-content/uploads/2017/08/OmniPlex-and-MAP-Offline-SDK-Bundle_0.zip
% https://plexon.com/software-downloads/#software-downloads-SDKs
if ~exist('plx_info', 'file')
    error('Plexon utilities (e.g. plx_info.m) may be missing, please check path or download from https://plexon.com/software-downloads/#software-downloads-SDKs\n');
end

files = dir('*.plx');
file_plx = files(end).name;
[tscounts, wfcounts, evcounts] = plx_info(file_plx, 1); % Full read is final argument
% The dimensions of the tscounts and wfcounts arrays are (NChan+1) x (MaxUnits+1)
tscounts = tscounts(:, 2:end); % Zero indexed surprisingly. First row = num unsorted units
[num_unit, num_ch] = size(tscounts);

num_sig = sum(tscounts(:)>0);
i_sig = 0;
cell_spikes = cell(num_sig, 1);
sig_name = cell(num_sig, 1);
for i_ch = 1:num_ch
    for i_unit = 1:num_unit
        if tscounts(i_unit, i_ch)
            [n, ts] = plx_ts(file_plx, i_ch, i_unit-1); % Matlab 1 indexed, but for unsorted ts: use 0 indexing
            i_sig = i_sig + 1;
            cell_spikes{i_sig} = ts;
            if i_unit == 1
                temp_char = '_';
            else
                temp_char = char('a' + i_unit - 2);
            end
            sig_name{i_sig} = sprintf('sig%03d%c', i_ch, temp_char);
        end
    end
end

%% Add neuron timestamps to nex structure
for i_sig = 1:numel(cell_spikes)
    nex = nexAddNeuron(nex, cell_spikes{i_sig}, sig_name{i_sig});
end

%% Write file
file_nex = [file_plx(1:end-3) 'nex'];
result = writeNexFile(nex, file_nex);
fprintf('File saved as %s\n', file_nex);

