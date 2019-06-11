function [trainDataPartition, valDataPartition] = Time_Cross_Val2(train)

rng(14)

time_shift = 260
size_train_set = 260 * 3
size_val_set = 260
set_shift = 30

train_size = size(train)
j = 1
group = 1
trainDataPartition = {}
valDataPartition = {}

while j + (size_train_set + size_val_set + set_shift) < train_size(1)
    trainset = [];
    valset = [];
    
    
    trainset = train(j:j+size_train_set, :); % array
    valset = train(j+size_train_set+1+set_shift:j+size_train_set+size_val_set+set_shift, :);
    
    trainDataPartition{group} = trainset;
    valDataPartition{group} = valset;
    
    group = group+1;
    j = j + time_shift;
    
    % make last set -- decide if you want to throw out or adjust this set
    trainset = train(j:j+size_train_set, :);
    valset = train(j+size_train_set+1+set_shift:end, :);
    
    trainDataPartition{group} = trainset;
    valDataPartition{group} = valset;
end

%%% Optional: force stratification
revised_trainDataPartition = {};

for i = 1:length(trainDataPartition)
    trainset = trainDataPartition{i};
    records = table2array(trainset(:,2)); % label index
    
    if sum(records == 1) == 0 || sum(records == 0) == 0
        continue
    elseif sum(records == 1) > sum(records == 0)
        while sum(records == 1) >= 1.3 * sum(records == 0)
            r = ceil(rand(1) * size(trainset, 1));
            if records(r) == 1;
                trainset(r,:) = [];
                records(r) = [];
            end
        end
        revised_trainDataPartition{i} = trainset;
    else
        while sum(records == 1) <= 1.3 * sum(records == 0)
            r = ceil(rand(1) * size(trainset, 1));
            if records(r) == 0
                trainset(r,:) = [];
                records(r) = [];
            end
        end
        revised_trainDataPartition{i} = trainset;
    end
end

trainDataPartition = revised_trainDataPartition;
group = length(revised_trainDataPartition)
end