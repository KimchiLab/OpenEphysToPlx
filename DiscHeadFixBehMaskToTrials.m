function [trial_data, beh_data] = DiscHeadFixBehMaskToTrials(mask_data, sec_dur, Fs, event_names, sec_between)

if nargin < 5
    sec_between = [1 1 0.05 1 0.4]; % Translate flexibly for diff input events? %%%
    if nargin < 4
        event_names = {'StimGo', 'StimOther', 'Lick', 'Reinforcer', 'Trial'};
        if nargin < 3
            Fs = 1e3; % Assumed for now, should be constant, can revise and pass in if changes
        end
    end
end
if nargin < 2 || isempty(sec_dur)
    sec_dur = 10e-3;
end

%% Check there is at least some positive TTL data
if sum(mask_data(:)) == 0
    fprintf('No behavioral events.\n');
    beh_data = [];
    trial_data = [];
    return;
end

%% From mask data to Event ts
% mask_go = strcmp(Events, 'StimGo');
% mask_reinf = strcmp(Events, 'Reinforcer');
bin_between = sec_between * Fs;

if numel(sec_dur) == 1
    % Then only trial duration passed in, make specific event min durations
    sec_dur = [0.2 0.2 0.01 0.02 sec_dur];
end
bin_dur = ceil(sec_dur * Fs);
min_bin_dur = 2;
bin_dur(bin_dur < min_bin_dur) = min_bin_dur; % Require at least 2 bins for each event

for i_event = 1:size(mask_data, 2)
    [idx_on, idx_off] = MaskToBouts(mask_data(:, i_event), bin_between(i_event), bin_dur(i_event));
%     [idx_trial_on, idx_trial_off] = MaskToBouts(mask_data(:, strcmp(Events, 'Trial')), bin_between);
    beh_data.(sprintf('%s_on', event_names{i_event})) = idx_on;
    beh_data.(sprintf('%s_off', event_names{i_event})) = idx_off;
end

%% Add in blank events if not present
field_names = {'StimGo', 'StimOther', 'Lick', 'Reinforcer', 'Trial', 'Opto'};

for i_field = 1:numel(field_names)
    temp_field = sprintf('%s_on', field_names{i_field});
    if ~isfield(beh_data, temp_field)
        beh_data.(temp_field) = [];
    end
    temp_field = sprintf('%s_off', field_names{i_field});
    if ~isfield(beh_data, temp_field)
        beh_data.(temp_field) = [];
    end
end

% %% Limit trials to only those at least certain duration: Now limited in MaskToBouts
% trial_dur = beh_data.Trial_off - beh_data.Trial_on;
% mask_valid = trial_dur >= min_bin_trial;
% beh_data.Trial_off = beh_data.Trial_off(mask_valid);
% beh_data.Trial_on = beh_data.Trial_on(mask_valid);

%% From Event ts to trials
if numel(beh_data.Trial_on) == 0
    trial_data = [];
else
    clear trial_data;
end

field_names = {'StimGo', 'StimOther', 'Reinforcer', 'Opto'};

% Create empty receiving vars
for i_field = 1:numel(field_names)
    temp_field_on = sprintf('%s_on', field_names{i_field});
    temp_field_off = sprintf('%s_off', field_names{i_field});
    temp_trial.(temp_field_on) = nan(1, numel(beh_data.Trial_on));
    temp_trial.(temp_field_off) = nan(1, numel(beh_data.Trial_on));
end

for i_trial = 1:numel(beh_data.Trial_on)
    idx_start = beh_data.Trial_on(i_trial);
    idx_end = beh_data.Trial_off(i_trial);
    trial_data.idx_start(i_trial) = idx_start;
    trial_data.idx_end(i_trial) = idx_end;
    
    for i_field = 1:numel(field_names)
        temp_field_on = sprintf('%s_on', field_names{i_field});
        temp_field_off = sprintf('%s_off', field_names{i_field});
        if isfield(beh_data, temp_field_on)
            idx = find(idx_start < beh_data.(temp_field_on) & beh_data.(temp_field_on) <= idx_end, 1);
            if ~isempty(idx)
                temp_trial.(temp_field_on)(i_trial) = beh_data.(temp_field_on)(idx);
                temp_trial.(temp_field_off)(i_trial) = beh_data.(temp_field_off)(idx);
            end
        end
    end
end
    
%% Redistribute into prior field names
if ~isempty(trial_data)
    trial_data.idx_stim_on = nansum([temp_trial.StimGo_on; temp_trial.StimOther_on]);
    trial_data.idx_stim_on(trial_data.idx_stim_on == 0) = NaN;
    trial_data.idx_stim_off = nansum([temp_trial.StimGo_off; temp_trial.StimOther_off]);
    trial_data.idx_stim_off(trial_data.idx_stim_off == 0) = NaN;
    trial_data.stim_class = repmat('0', size(trial_data.idx_stim_on));
    trial_data.stim_class(~isnan(temp_trial.StimGo_on)) = 'G';
    trial_data.stim_class(~isnan(temp_trial.StimOther_on)) = 'N';

    trial_data.idx_reinf_on = temp_trial.Reinforcer_on;
    trial_data.idx_reinf_off = temp_trial.Reinforcer_off;
    trial_data.reinf = repmat('0', size(trial_data.idx_reinf_on));
    trial_data.reinf(~isnan(temp_trial.Reinforcer_on)) = 'R';

    trial_data.idx_opto_on = temp_trial.Opto_on;
    trial_data.idx_opto_off = temp_trial.Opto_off;
    trial_data.opto = false(size(trial_data.idx_opto_on));
    trial_data.opto(~isnan(temp_trial.Opto_on)) = true;
end


%% Prior trial by trial parsing code
%     % Stim
%     idx_go = find(idx_start < beh_data.StimGo_on & beh_data.StimGo_on < idx_end);
%     if isfield(beh_data, 'StimOther_on')
%         idx_other = find(idx_start < beh_data.StimOther_on & beh_data.StimOther_on < idx_end);
%     else
%         idx_other = [];
%     end
%     if ~isempty(idx_go)
%         idx_go = idx_go(1); % If more than 1 trial caught due to noisy signal, temp place/fix
%         trial_data.idx_stim_on(i_trial) = beh_data.StimGo_on(idx_go);
%         trial_data.idx_stim_off(i_trial) = beh_data.StimGo_off(idx_go);
%         trial_data.stim_class(i_trial) = 'G';
%     elseif ~isempty(idx_other)
%         idx_other = idx_other(1); % If more than 1 trial caught due to noisy signal, temp place/fix
%         trial_data.idx_stim_on(i_trial) = beh_data.StimOther_on(idx_other);
%         trial_data.idx_stim_off(i_trial) = beh_data.StimOther_off(idx_other);
%         trial_data.stim_class(i_trial) = 'N';
%     else
%         trial_data.idx_stim_on(i_trial) = NaN;
%         trial_data.idx_stim_off(i_trial) = NaN;
%         trial_data.stim_class(i_trial) = '0';
%     end
%     
%     % Reinforcer
%     idx = find(idx_start < beh_data.Reinforcer_on & beh_data.Reinforcer_on < idx_end);
%     if ~isempty(idx)
%         idx = idx(1); % If more than 1 trial caught due to noisy signal, temp place/fix
%         trial_data.idx_reinf_on(i_trial) = beh_data.Reinforcer_on(idx);
%         trial_data.reinf(i_trial) = 'R';
%     else
%         trial_data.idx_reinf_on(i_trial) = NaN;
%         trial_data.reinf(i_trial) = '0';
%     end
%     
%     % Opto
%     if isfield(beh_data, 'Opto_on')
%         idx = find(idx_start < beh_data.Opto_on & beh_data.Opto_on < idx_end);
%         
%         idx_other = find(idx_start < beh_data.StimOther_on & beh_data.StimOther_on < idx_end);
%     else
%         idx_other = [];
%     end
%     if ~isempty(idx_go)
%         idx_go = idx_go(1); % If more than 1 trial caught due to noisy signal, temp place/fix
%         trial_data.idx_stim_on(i_trial) = beh_data.StimGo_on(idx_go);
%         trial_data.idx_stim_off(i_trial) = beh_data.StimGo_off(idx_go);
%         trial_data.stim_class(i_trial) = 'G';
%     elseif ~isempty(idx_other)
%         idx_other = idx_other(1); % If more than 1 trial caught due to noisy signal, temp place/fix
%         trial_data.idx_stim_on(i_trial) = beh_data.StimOther_on(idx_other);
%         trial_data.idx_stim_off(i_trial) = beh_data.StimOther_off(idx_other);
%         trial_data.stim_class(i_trial) = 'N';
%     else
%         trial_data.idx_stim_on(i_trial) = NaN;
%         trial_data.idx_stim_off(i_trial) = NaN;
%         trial_data.stim_class(i_trial) = '0';
%     end
% end

if ~isempty(trial_data)
    stim_delay = nanmedian(trial_data.idx_stim_on - trial_data.idx_start);
    for i_trial = 1:numel(beh_data.Trial_on)
        ts_stim = trial_data.idx_stim_on(i_trial);
        if isnan(ts_stim)
            ts_stim = trial_data.idx_start(i_trial) + stim_delay;
        end
        % Response: Has to be in relationship to time swtim WOULD come on for "silent" trials
        idx = find(ts_stim < beh_data.Lick_on & beh_data.Lick_on < trial_data.idx_end(i_trial));
        if ~isempty(idx)
            idx = idx(1); % If more than 1 trial caught due to noisy signal, temp place/fix
            trial_data.idx_resp_on(i_trial) = beh_data.Lick_on(idx);
            trial_data.resp(i_trial) = 'L';
        else
            trial_data.idx_resp_on(i_trial) = NaN;
            trial_data.resp(i_trial) = '0';
        end

    end
end

