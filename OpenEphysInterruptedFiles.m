% file_type = 'CH' or 'ADC'
function files = OpenEphysInterruptedFiles(dir_name, file_type)

if nargin < 2
    fprintf('No file type given for OpenEphysInterruptedFiles\n');
    files = [];
    return;
end

%% Ignore discontinuous recording files: flagged with _n, e.g. 100_CH10_2.continuous
cd(dir_name);
files = dir(sprintf('*_%s*.continuous', file_type));
[~, sort_idx] = sort_nat({files.name}); % Since saved as 1..9, 10..16
files = files(sort_idx);
% Several kinds of directories: No suffix, Suffix only (>= 1), Mix
mask_nosuffix = cellfun(@isempty, regexp({files.name}, '^\d+_CH\d+_\d+'));
% If there are no suffix files, then accept them as correct files, disregard rest
if sum(mask_nosuffix)
    files = files(mask_nosuffix);
    % Were there files with suffixes? If so, flag interrupted files
    if numel(files) ~= numel(mask_nosuffix)
        fprintf('Interrupted files present, ignored.\n');
    end
else
    % If all files have suffixes, then choose first
    [a, b, c, d, e, f, g] = regexp({files.name}, '^\d+_CH\d+(_\d+)', 'tokens', 'match');
    all_suffix = [a{:}];
    [name_suffix, ~, hash_suffix] = unique([all_suffix{:}]);
    mask_suffix = hash_suffix == 1;
    files = files(mask_suffix);
    fprintf('Only interrupted files present, kept first set.\n');
end

