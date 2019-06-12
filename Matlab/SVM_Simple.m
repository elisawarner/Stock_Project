%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% RUN PCA AND SVM
%%%% Date: 5/30/2019
%%%% Author: Elisa Warner
%%%%
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

rng 'default'

X = readtable('../Python/Combined_Sets_from_Revised.csv');
X = X(3:7100, 1:149);
X(:, [123 127 131 135 139]) = [];
%X = X(4183:6183,:);
%X.google_hits67 = cellfun(@(x) str2num(x), X.google_hits67) % R2018a only

%varnames = X.Properties.VariableNames
%varnames{2} = 'labels'
%X.Properties.VariableNames = varnames
labels = table2array(X(:,2));
dates = X(:,1);
X = X(:,3:end);
X = table2array(X);

% Do the PCA
[coeff,score,latent] = pca(X, 'NumComponents', 13);
M = horzcat(labels, score);
M = array2table(M);
M = [dates M]
varnames = {'Dates', 'labels', 'PCA1', 'PCA2', 'PCA3', 'PCA4',...
    'PCA5', 'PCA6', 'PCA7', 'PCA8', 'PCA9', 'PCA10',  'PCA11', 'PCA12',...
    'PCA13'} %, 'PCA14', 'PCA15', 'PCA16', 'PCA17', 'PCA18', 'PCA19', ...
    %'PCA20', 'PCA21', 'PCA22', 'PCA23', 'PCA24',...
    %'PCA25', 'PCA26', 'PCA27', 'PCA28', 'PCA29', 'PCA30',  'PCA31', 'PCA32',...
    %'PCA33', 'PCA34', 'PCA35', 'PCA36', 'PCA37', 'PCA38', 'PCA39', 'PCA40',...
    %'PCA41', 'PCA42', 'PCA43', 'PCA44','PCA45', 'PCA46'}
M.Properties.VariableNames = varnames;

[trainDataPartition, valDataPartition] = Time_Cross_Val2(M);
[normTrain, normVal] = Normalize(trainDataPartition, valDataPartition, varnames)
[grid, grid_train, grid_std, resultData] = SVM(normTrain, normVal)
make_priv_set