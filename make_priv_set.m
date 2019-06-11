%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make Privileged Set
%%%
%%% Creates the privileged information set by concatenating the 
%%% (i + 1) column onto row i
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Adjust Variable Names
newTrainDataPartition = {}
varnames = trainDataPartition{1,1}.Properties.VariableNames
for i = 1:length(varnames)
    varnames{i} = strcat(varnames{i}, '_2')
end

for i = 1:length(trainDataPartition)
    fold = trainDataPartition{1,i};
    temp_cell = {};
    for j = 1:size(fold, 1)-1 % number of rows
        priv_row = fold(j+1, :);
        priv_row.Properties.VariableNames = varnames; % rename cols
        original_row = fold(j, :);
        temp_cell = [temp_cell; horzcat(original_row, priv_row)];
    end
    newTrainDataPartition{1,i} = temp_cell;
end