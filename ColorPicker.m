function color = ColorPicker(string)


switch(lower(string))
    case {'black'}
        color = [1 1 1]; % to distinguish in illustrator
    case {'gray'}
        color = repmat(128,1,3);
    case {'darkgray'}
        color = repmat(51,1,3);
    case {'medgray'}
        color = repmat(140,1,3);
    case {'lightgray'}
        color = repmat(203,1,3);
    case {'blue'}
        color = [0 114 178];
    case {'darkblue'}
        color = [0 0 150];
    case {'skyblue'}
        color = [86, 180, 233];
    case {'lightblue'}
        color = [190, 230, 255];
    case {'turquoise'}
%         color = [0, 158, 115]; % from CB website?
        color = [0, 148, 126]; % from CMYK 100 0 50 0
    case {'red'}
        color = [235 0 0]; % from CB website?
%         color = [235 0 0]; % from CMYK 0 100 100 0
%         color = [230 50 50]; % To work with ColorLighten
    case {'redlighten'}
        color = [230 50 50]; % To work with ColorLighten
    case {'lightred'}
        color = [250 150 100];
    case {'mutedred'}
        color = [200 100 50];
%         color = [200 120 60];
%         color = [230 159 0];
    case {'purple'}
        color = [170 100 190];
    case {'darkpurple'}
        color = [170 100 190] * 0.6;
    case {'magenta'}
        color = [255 0 230];
    case {'vermillion'}
        color = [213 94 0];
    case {'lightpurple'}
        color = [204 121 167];
    case {'cyan'}
        color = [0 255 255];
    case {'brown'}
        color = [180 80 0];
    case ('beige')
        color = [249 220 190];
    case {'green'}
        color = [80 220 0];
    case {'darkgreen'}
        color = [20 120 0];
    case {'orange'}
        color = [230 130 0];
    case {'pink'}
        color = [255 220 220];
    case {'darkpink'}
%         color = [250 150 100];
%         color = [255 220 220] * 0.8;
        color = [210 160 170];
    case {'burntorange'}
        % color = [213, 110, 0];
        color = [230, 90, 0];
    case {'yellow'}
        color = [240 228 66];
    case {'canary'}
%         color = [255 211 25];
        color = [230 180 25];
    case {'gold'}
        color = [150 140 0];
    case {'white'}
        color = [254 254 254];
    case {'tonyshock'}
        color = [237 125 49];
    case {'tonysucrose'}
        color = [140 100 175];
    case {'tonycomp'}
        color = [112 173 71];
    case {'brewerblue'}
        color = [55,126,184];
    case {'brewergreen'}
        color = [77,175,74];
    case {'brewerpurple'}
        color = [152,78,163];
    case {'brewerred'}
        color = [228,26,28];
    case {'brewerorange'}
        color = [255,127,0];
    otherwise
        color = [1 1 1];
end

color = color/255;
    
