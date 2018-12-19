function dur = TimeUpdate(i_step, num_steps)

dur = toc;

% fprintf('%3d/%3d: t= %3.0f sec; %3.0f / %3.0f\n', i_step, num_steps, dur / i_step * num_steps, dur, dur / i_step * (num_steps - i_step));
% fprintf('Step %3d of %3d: Est total= %3.0f sec; T 1:i %3.0f / T i+1:n %3.0f\n', i_step, num_steps, dur / i_step * num_steps, dur, dur / i_step * (num_steps - i_step));
fprintf('Step %3d of %2d: %3.0f s elapsed, est %3.0f s left of %3.0f s (%s)\n', i_step, num_steps, dur, dur / i_step * (num_steps - i_step), dur / i_step * num_steps, datestr(now, 'HH:MM:SS PM on mm/dd/yy'));
% est T= %3.0f s; done %3.0f / left %3.0f as of %s\n', i_step, num_steps, dur / i_step * num_steps, dur, dur / i_step * (num_steps - i_step), datestr(now, 'HH:MM:SS on mm/dd/yy'));

% Only print for intervals greater than cutoff
% below fails since checks total duration, not interval duration
% cutoff = 10; % only print if greater than this cutoff
% if dur > cutoff
%     fprintf('%3d/%3d: t= %3.0f sec; %3.0f / %3.0f\n', i_step, num_steps, dur / i_step * num_steps, dur, dur / i_step * (num_steps - i_step));
% end

% waitbar(i_step, num_steps);
