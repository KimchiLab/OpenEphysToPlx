function limits = AxesSharedLimits(grid_axes, limits)

if nargin < 2
    limits = nan(1, 4);
end

num_axes = numel(grid_axes);

x_lim = nan(num_axes, 2);
y_lim = nan(num_axes, 2);

for i_ax = 1:num_axes
    if (grid_axes(i_ax) > 0 || ~isempty(grid_axes)) && strcmp('on', get(grid_axes(i_ax), 'Visible'))
        x_lim(i_ax, :) = xlim(grid_axes(i_ax));
        y_lim(i_ax, :) = ylim(grid_axes(i_ax));
        if sum(abs(y_lim(i_ax, :)) == inf)
            temp_lim = YLimFromDataGCA(grid_axes(i_ax));
            if y_lim(i_ax, 1) == -inf
                temp_lim = YLimFromDataGCA;
                y_lim(i_ax, 1) = temp_lim(1);
            end
            if y_lim(i_ax, 2) == inf
                y_lim(i_ax, 2) = temp_lim(2);
            end        
        end
    end
end

x_min = min(x_lim(:,1));
x_max = max(x_lim(:,end));
y_min = min(y_lim(:,1));
y_max = max(y_lim(:,end));

temp_limits = [x_min x_max, y_min y_max];

limits(isnan(limits)) = temp_limits(isnan(limits));
% limits(isnan(limits)) = 0;
if isnan(limits(1)) && isnan(limits(2))
	limits(1) = 0;
    limits(2) = 1;
end
if isnan(limits(3)) && isnan(limits(4))
	limits(3) = 0;
    limits(4) = 1;
end

for i_ax = 1:num_axes
    if grid_axes(i_ax) > 0 && strcmp('on', get(grid_axes(i_ax), 'Visible'))
        axis(grid_axes(i_ax), limits);
    end
end
