# OpenEphysToPlx
Convert open ephys files to plx format files using Matlab, for sorting in Plexon OffLineSorter.

The general workflow is:
1) **OpenEphysToCommonRef.m**: Generate a Common Average Reference and subtract it from each channel
2) **OpenEphysRefToSpikesPlexon.m**: Filter each referenced channel and extract spikes to write a plexon file
a next step can include
3) **OpenEphysAdcToMatlab.m**: Convert ADC files to matlab data: extract events and treadmill data

The input to each argument is the directory in which the continuous data files are.

You can also use the script **OpenEphysToPlexon_Script.m** to automatically process a number of subdirectories.

This repository does contain some files from https://github.com/open-ephys/analysis-tools and natural order sort from https://www.mathworks.com/matlabcentral/fileexchange/10959-sort_nat-natural-order-sort (other natural order sort functions include https://www.mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort )

The current version of plexon file writing was adapated from a file by Praneeth Namburi.
