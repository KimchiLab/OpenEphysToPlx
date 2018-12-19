% function [data] = FilterSpikes(ad, Fs, freq_lo, freq_hi, notch_flag);
%
% this is Mark Laubach's filter for neural data
% originally a part of a spike sorting function
% pulled out by eyal into a separate function
%
% first applies a bandpass filter from low to hi
% then can apply a notch filter from 59-61 Hz
%
% defaults are for Spikes data
% sampling frequency 30 kHz (i.e. 30e3)
% low cutoff = 0.5 kHz
% high cutoff = 5 kHz

%%% Modified on 2012/11/09 to use filtfilt instead of fwd & bwd filter
% The edge effects appear to be inconsistent between filtfilt vs. filter->fliplr(filter(fliplr)?
% filtfilt gives more edge effects with random data (or Sin wave data including an EEG channel w/prominent 60Hz noise), but
% filter->fliplr... gives more edge effects with EEG data?!
% filter->fliplr... can actually invert or shift phases too?!

function data = FilterSpikes(ad, Fs, freq_lo, freq_hi, notch_flag)

if nargin < 5
    notch_flag = false;
    if nargin < 3
        freq_lo=0.3e3;
        freq_hi=6e3;
        if nargin < 2
            Fs = 30e3;
        end
    end
end

Nyq = Fs/2;
deg=4; % 5 appropriate for broad filtering in FilterSpikes, should be 2 for smaller Hz ranges (eg. 1-3 Hz). 4 from multiple web findings: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5373639/, http://gaidi.ca/weblog/extracting-spikes-from-neural-electrophysiology-in-matlab
% choice of 3 for EEG is from Cat Chu Shore's NORMAL_INFANTS_filter_ref_B.m
% getting filter shape here in next step does add time to repeat for each channel, consider doing in parent function?

Wn = [freq_lo freq_hi] / Nyq;
[b,a]=butter(deg,Wn, 'bandpass');

% Convert int to double for filtering
if ~isfloat(ad)
    ad = double(ad);
end
data = filtfilt(b,a,ad);

% Notch filter: not working currently: returning NaN?!
if notch_flag
    Wn = [59 61] / Nyq;
    [b,a]=butter(2, Wn, 'stop'); % Lower degree for narrower filtering: use deg=5 above led to NaNs
    data=filtfilt(b,a,data);    
end
