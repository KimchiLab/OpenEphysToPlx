function h = PlotSpecGram(t, f, p)

% % Advantage of plotting with surf: can use log scales and rotate in 3D
% % Disadvantage of plotting with surf: Data now has a z dimension, which complicates any zero lines
% h = surf(t, f, p, 'EdgeColor','none');
% axis xy; 
% view(0,90);

% Imagesc: 2D based on outer edges
h = imagesc(t, f, p);

set(gca, 'YDir', 'normal');
ylabel('Freq (Hz)');
xlabel('Peri-event (sec)');
