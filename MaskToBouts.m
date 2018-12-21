function [idx_on, idx_off] = MaskToBouts(data, bin_between, min_dur_bin, max_dur_bin)

if nargin < 4
    max_dur_bin = inf;
    if nargin < 3
        min_dur_bin = 0;
    end
end

%% Calc bouts
data = data(:);
idx_on = find(diff([false; data]) > 0);
idx_off = find(diff([false; data]) < 0);

%% Refine results
if ~isempty(idx_on)
    if numel(idx_off) == numel(idx_on) - 1
       fprintf('Unfinished trial at end during MaskToBouts?\n')
       idx_on = idx_on(1:end-1);
%        idx_off = [idx_off; numel(data)]; % May lead to timestamps that fall off the end of the data when syncing to stimuli
    end

    % Restrict by being at least some distance apart from next event.
    % If less than min distance apart, lump together
    % Allows for interrupted events to be grouped together: Maybe have multiple step process of In/small-Out-In/larger?
    idx_between = idx_on(2:end) - idx_off(1:end-1);
    mask_valid = idx_between > bin_between; % assume accept first
    idx_on = idx_on([true; mask_valid]);
    idx_off = idx_off([mask_valid; true]);
    
    % Restrict by requiring minimum duration
    dur = idx_off - idx_on;
    mask_dur = min_dur_bin < dur;
    idx_on = idx_on(mask_dur);
    idx_off = idx_off(mask_dur);
    
    % Restrict by limiting maximum duration
    dur = idx_off - idx_on;
    mask_dur = dur < max_dur_bin;
    idx_on = idx_on(mask_dur);
    idx_off = idx_off(mask_dur);
    
end

% %% Plot results
% clf;
% hold on;
% plot(data, '.');
% axis tight;
% data_refined = false(size(data));
% for i = 1:numel(idx_on)
%     data_refined(idx_on(i):idx_off(i)-1) = true;
% end
% plot(data_refined);
