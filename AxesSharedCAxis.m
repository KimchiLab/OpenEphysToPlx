function limits = AxesSharedCAxis(grid_axes, limits)

if nargin < 2
    limits = nan(1, 2);
end

num_axes = numel(grid_axes);

c_lim = nan(num_axes, 2);

for i_ax = 1:num_axes
    if strcmp('on', get(grid_axes(i_ax), 'Visible'))
        c_lim(i_ax, :) = caxis(grid_axes(i_ax));
    end
end

c_min = nanmin(c_lim(:,1));
c_max = nanmax(c_lim(:,end));

temp_limits = [c_min c_max];

limits(isnan(limits)) = temp_limits(isnan(limits));

for i_ax = 1:num_axes
    if strcmp('on', get(grid_axes(i_ax), 'Visible'))
        caxis(grid_axes(i_ax), limits);
    end
end
