%% OLM scored data prepocessor
% Charles Xu @ UCSD, initial version 20221008
% Reads data from raw scoring output files and processes it into a combined
% data table for further analysis
%
%% Import data
% Set up import options
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = [1, Inf];
opts.Delimiter = ":";

% Specify column names and types
opts.VariableNames = ["MouseID", "VarName2", "VarName3"];
opts.VariableTypes = ["categorical", "double", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "VarName3", "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["MouseID", "VarName3"], "EmptyFieldRule", "auto");

% Import the data
trnPath = uigetdir('*.trn', 'Choose the trn file.');
trnFiles = dir(fullfile(trnPath,'*.trn'));
trnData = cell(length(trnFiles),1);
nFiles = size(trnFiles,1);
for f = 1:nFiles
   trnData{f,1} = readtable(fullfile(trnPath, trnFiles(f).name), opts);
end

clearvars -except trnData nFiles

%% Process data into combined table
% Grab data to create variables
[MouseID, RecDay, Maze] = deal(string(zeros(1,nFiles)));
[nExpLeft, nExpRight, tExpLeft, tExpRight, Ratio, tExpTotal, tSession] = deal(zeros(1, nFiles));

for f = 1:nFiles
    currentFile = trnData{f,1};
    fileID = num2str(currentFile{currentFile.MouseID=='MouseID',2});
    
    if fileID(1) == '4'
        MouseID(f) = 'SP4';
    elseif fileID(1) == '5'
        MouseID(f) = 'SP5';
    elseif fileID(1) == '6'
        MouseID(f) = 'SP6';
    elseif fileID(1) == '8'
        MouseID(f) = 'SP8';
    else
        MouseID(f) = '';
    end
    
    if fileID(2) == '4'
        RecDay(f) = 'training';
    elseif fileID(2) == '5'
        RecDay(f) = 'testing';
    end
    
    if fileID(3) == '0'
        Maze(f) = 'round';
    elseif fileID(3) == '1'
        Maze(f) = 'square';
    else
        Maze(f) = '';
    end
    
    nExpLeft(f) = currentFile{currentFile.MouseID=='Left Object Explorations',2};
    nExpRight(f) = currentFile{currentFile.MouseID=='Right Object Explorations',2};
    tExpLeft(f) = currentFile{currentFile.MouseID=='Total Left Object Time',2};
    tExpRight(f) = currentFile{currentFile.MouseID=='Total Right Object Time',2};
    Ratio(f) = currentFile{currentFile.MouseID=='Left/Right Time Ratio',2};
    tExpTotal(f) = currentFile{currentFile.MouseID=='Total Object Time',2};
    tSession(f) = currentFile{currentFile.MouseID=='Session Duration',2};
end

DI = (tExpLeft-tExpRight)./(tExpLeft+tExpRight);
    
% Combine to table
OLMScoredData = table(MouseID', RecDay', Maze', nExpLeft', nExpRight', tExpLeft', tExpRight', Ratio', DI', tExpTotal', tSession',...
                       'VariableNames',["MouseID", "RecDay", "Maze", "nExpMoved", "nExpUnmoved", "tExpMoved", "tExpUnmoved", "Ratio", "DI", "tExpTotal", "tSession"]);

clearvars -except OLMScoredData

%% Manually assign condition
Condition = ["CNO" "saline" "no injection" "no injection" "CNO" "saline" "no injection" "no injection" "saline" "CNO" "no injection" "no injection" "saline" "CNO" "no injection" "no injection"]';
OLMScoredData.Condition = Condition;

%% Visualize data
args = input('Visualize data? yes/no (y/n)','s');
if (args == "yes") | (args == 'y') %#ok<OR2>
    titleSize = 15;
    % Ratio: CNO in blue, saline in red
    figure
    plot([0 1], [OLMScoredData.Ratio(1), OLMScoredData.Ratio(3); OLMScoredData.Ratio(5), OLMScoredData.Ratio(7); OLMScoredData.Ratio(10), OLMScoredData.Ratio(12); OLMScoredData.Ratio(14), OLMScoredData.Ratio(16)], 'b',...
    [0 1], [OLMScoredData.Ratio(2), OLMScoredData.Ratio(4); OLMScoredData.Ratio(6), OLMScoredData.Ratio(8); OLMScoredData.Ratio(9), OLMScoredData.Ratio(11); OLMScoredData.Ratio(13), OLMScoredData.Ratio(15)], 'r')
    xlim([-0.5 1.5])
    title('Ratio: CNO in blue, saline in red', 'Fontsize', titleSize)
    
    % Make is so that the numbers are the proportion of the average between
    % two days to normalize among rats

    % DI: saline on left, CNO on right
    figure
    scatter([0 1 0 1 1 0 1 0], OLMScoredData.DI([3,4,7,8,11,12,15,16]))
    xlim([-0.5 1.5])
    title('DI: CNO on left, saline on right', 'Fontsize', titleSize)
else
end

