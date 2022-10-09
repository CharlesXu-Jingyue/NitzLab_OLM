%% OLM scored data prepocessor
% Charles Xu @ UCSD, initial version 20221008
% Reads data from raw scoring output files and processes it into a combined
% data table for further analysis
%
%% Read raw data
trnPath = uigetdir('*.trn', 'Choose the trn file.');
load(fullfile(trnPath, 'videoNO440.trn'));