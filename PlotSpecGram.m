function h = PlotSpecGram(t, f, p)

h = imagesc(t, f, p);
% h = surf(t, f, p, 'EdgeColor','none');
set(gca, 'YDir', 'normal');
% axis xy; 
% view(0,90);
ylabel('Freq (Hz)');
xlabel('Peri-event (sec)');
