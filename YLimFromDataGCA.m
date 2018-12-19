function y_lim = YLimFromDataGCA(temp_axes)

if nargin < 1
    temp_axes = gca;
end

num_axes = numel(temp_axes);

y_lim = nan(num_axes, 2);

for i_ax = 1:num_axes
    axes(temp_axes(i_ax));
    
    % Can do something simpler for R23013a
    temp_ver = version('-release');
    temp_date = str2double(temp_ver(1:4));

    temp_data = [];
    cell_data = [];
    
    children = get(gca, 'Children');
    for i_child = 1:numel(children)
        child = get(children(i_child));
        if isfield(child, 'YData')
            cell_data = child.YData;
            if iscell(cell_data)
                for i_cell = 1:numel(cell_data)
                    temp_data = [temp_data; cell_data{i_cell}(:)];
                end
            else
                temp_data = [temp_data; cell_data(:)];
            end
        end
    end
    temp_min = temp_data;
    temp_min(temp_min == -inf) = inf;
    if ~isempty(temp_min)
        y_lim(i_ax, 1) = min(temp_min(:));
    end

    temp_max = temp_data;
    temp_max(temp_max == inf) = -inf;
    if ~isempty(temp_max)
        y_lim(i_ax, 2) = max(temp_max(:));
    end

end
