% ExportIll.m
% Eyal Kimchi, uploaded 2019
% Function to try to streamline export of Matlab figures to a PNG file
% 
% More info:
% http://neuropsyence.blogspot.com/2007/12/making-figures-matlab-to-illustrator.html
%
% Some prior references: (some no longer active)
% https://www.mathworks.com/matlabcentral/fileexchange/23629-export_fig
% https://www.mathworks.com/matlabcentral/fileexchange/7401-scalable-vector-graphics-svg-export-of-figures
% http://www.mathworks.com/support/solutions/data/1-1B33H.html?solution=1-1B33H
% http://www.mathworks.com/support/solutions/data/1-19LQF.html?solution=1-19LQF
% http://www.sccn.ucsd.edu/eeglab/printfig.html

function ExportPNG(save_name, paper_size)

if nargin < 2
    paper_size = [11 8.5];
    if nargin < 1
        % If no save_name is passed in, then use a temporary directory/file
        % This may cause an error if it does not exist
        if exist('C:\temp', 'dir')
            save_name = 'C:\temp\temp';
        else
            fprintf('Please input a save file name or change default save dir in code\n');
            return;
        end
    end
end

warning('off', 'MATLAB:print:DeprecatedOptionAdobecset');
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', paper_size);
% set(gcf, 'PaperOrientation', 'landscape');
set(gcf, 'PaperOrientation', 'portrait');
set(gcf, 'PaperPosition', [.25 .25 paper_size-0.5]);

resolution = '-r600';

print('-dpng', '-noui', '-painters', resolution, save_name);

% If no filename was given, then "run" the temp file: will open whatever program is associated with ps files
if nargin < 1
    eval(['!' save_name '.png']);
end
