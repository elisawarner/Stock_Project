%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Normalize Dataset
%%%% Najarian Lab
%%%% Author: Elisa Warner
%%%% 01/07/2019
%%%%
%%%% Purpose: Normalize a matrix by column
%%%% Input: the 1xK Data Partition cells from Cross_Validation.m
%%%% Output: a 1xK Normalized Data Partition table by column
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [normTrain, normVal] = Normalize(trainDataPartition, valDataPartition, varnames)

type_list = ["train", "val"];
skip = 2 % skip first two columns
normTrain = {};
normVal = {};

for j = 1:size(trainDataPartition, 2);
    min_param = {};
    max_param = {};
    for type = 1:length(type_list)
        % save parameters for validation set
        
        header = 1; % if true, header = 1

        if type == 1
            M = trainDataPartition{j};
        else
            M = valDataPartition{j};
        end

        % the new, normalized matrix
        A = [];

        for i = 1+skip:size(M,2);
            col = table2array(M(:,i));
            if type == 1 % train
                min_param{1, i} = min(col); %[min_param; min(col)];
                max_param{1, i} = max(col); %[max_param; max(col)];
            end
            try
                min_col = min_param{1, i};
                max_col = max_param{1, i};
                normalized_col = (col - min_col) ./ (max_col - min_col);    
                
                if max_col - min_col == 0
                    normalized_col = zeros(length(col), 1);
                end
                
                A = [A; normalized_col'];
            catch
                continue % sometimes the training set is empty because no balance in examples
            end
        end

        A = A';

        if isempty(A)
            continue
        end
        
        A = array2table(A);
        A = [M(:,1) M(:,2) A]; % M(:,2)
        A.Properties.VariableNames = varnames;

        if type == 1
            normTrain{j} = A;
        else
            normVal{j} = A;
        end
    end
end
end
