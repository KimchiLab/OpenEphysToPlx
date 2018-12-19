function header = load_open_ephys_header(filename)
%
% [data, timestamps, info] = load_open_ephys_data(filename, [outputFormat])
%
%   Loads continuous, event, or spike data files into Matlab.
%
%   Inputs:
%
%     filename: path to file
%
%   Outputs:
%     info: structure with header and other information
%

[~,~,filetype] = fileparts(filename);
if ~any(strcmp(filetype,{'.events','.continuous','.spikes'}))
    error('File extension not recognized. Please use a ''.continuous'', ''.spikes'', or ''.events'' file.');
end

bInt16Out = false;
if nargin > 2
    error('Too many input arguments.');
elseif nargin == 2
    if strcmpi(varargin{1}, 'unscaledInt16')
        bInt16Out = true;
    else
        error('Unrecognized output format.');
    end
end

fid = fopen(filename);
fseek(fid,0,'eof');
filesize = ftell(fid);

NUM_HEADER_BYTES = 1024;
fseek(fid,0,'bof');
hdr = fread(fid, NUM_HEADER_BYTES, 'char*1');
info = getHeader(hdr);
if isfield(info.header, 'version')
    version = info.header.version;
else
    version = 0.0;
end

switch filetype
    case '.events'
        bStr = {'timestamps' 'sampleNum' 'eventType' 'nodeId' 'eventId' 'data' 'recNum'};
        bTypes = {'int64' 'uint16' 'uint8' 'uint8' 'uint8' 'uint8' 'uint16'};      
        bRepeat = {1 1 1 1 1 1 1};
        dblock = struct('Repeat',bRepeat,'Types', bTypes,'Str',bStr);
        if version < 0.2, dblock(7) = [];  end
        if version < 0.1, dblock(1).Types = 'uint64'; end
    case '.continuous'
        SAMPLES_PER_RECORD = 1024;
        bStr = {'ts' 'nsamples' 'recNum' 'data' 'recordMarker'};
        bTypes = {'int64' 'uint16' 'uint16' 'int16' 'uint8'};
        bRepeat = {1 1 1 SAMPLES_PER_RECORD 10};
        dblock = struct('Repeat',bRepeat,'Types', bTypes,'Str',bStr);
        if version < 0.2, dblock(3) = []; end
        if version < 0.1, dblock(1).Types = 'uint64'; dblock(2).Types = 'int16'; end
    case '.spikes'
        num_channels = info.header.num_channels;
        num_samples = 40; 
        bStr = {'eventType' 'timestamps' 'timestamps_software' 'source' 'nChannels' 'nSamples' 'sortedId' 'electrodeID' 'channel' 'color' 'pcProj' 'samplingFrequencyHz' 'data' 'gain' 'threshold' 'recordingNumber'};
        bTypes = {'uint8' 'int64' 'int64' 'uint16' 'uint16' 'uint16' 'uint16' 'uint16' 'uint16' 'uint8' 'float32' 'uint16' 'uint16' 'float32' 'uint16' 'uint16'};
        bRepeat = {1 1 1 1 1 1 1 1 1 3 2 1 num_channels*num_samples num_channels num_channels 1};
        dblock = struct('Repeat',bRepeat,'Types', bTypes,'Str',bStr);
        if version < 0.4,  dblock(7:12) = []; dblock(8).Types = 'uint16'; end
        if version == 0.3, dblock = [dblock(1), struct('Repeat',1,'Types','uint32','Str','ts'), dblock(2:end)]; end
        if version < 0.3, dblock(2) = []; end
        if version < 0.2, dblock(9) = []; end
        if version < 0.1, dblock(2).Types = 'uint64'; end
end
blockBytes = str2double(regexp({dblock.Types},'\d{1,2}$','match', 'once')) ./8 .* cell2mat({dblock.Repeat});
numIdx = floor((filesize - NUM_HEADER_BYTES)/sum(blockBytes));
header = info.header;

end
function info = getHeader(hdr)
eval(char(hdr'));
info.header = header;
end
