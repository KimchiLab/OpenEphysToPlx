function dir_name = dirDropboxKimchiLab()

% if exist('C:\Users\Eyal\Dropbox')
%     dir_name = 'C:\Users\Eyal\Dropbox');
%     dir_name = pwd;
if exist('D:\Dropbox (KimchiLab)','dir')
    dir_name = 'D:\Dropbox (KimchiLab)';
elseif exist('C:\Dropbox (KimchiLab)','dir')
    dir_name = 'C:\Dropbox (KimchiLab)';
elseif exist('D:\Doc\Dropbox','dir')
    dir_name = 'D:\Doc\Dropbox';
elseif exist('C:\Doc\Dropbox','dir')
    dir_name = 'C:\Doc\Dropbox';
elseif exist('C:\Users\Eyal\Dropbox (KimchiLab)', 'dir');
    dir_name = 'C:\Users\Eyal\Dropbox (KimchiLab)';
elseif exist('C:\Users\TDT3\Dropbox (MIT)', 'dir')
    dir_name = 'C:\Users\TDT3\Dropbox (MIT)\OpBoxPhysShare';
else
    fprintf('Dropbox KimchiLab not found.\n');
    dir_name = [];
end
