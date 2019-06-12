function [trainDataPartition, valDataPartition] = Time_Cross_Val2(train)

rng(14)

size_train_set = 410;
size_val_set = 260;
set_shift = 30;
time_shift = size_train_set + size_val_set + set_shift;

train_size = size(train);
j = 1;
group = 1;
trainDataPartition = {};
valDataPartition = {};

while j + (size_train_set + size_val_set + set_shift) < train_size(1)
    trainset = [];
    valset = [];
    
    trainset = train(j:j+size_train_set, :); % array
    valset = train(j+size_train_set+1+set_shift:j+size_train_set+size_val_set+set_shift, :);
    
    trainDataPartition{group} = trainset;
    valDataPartition{group} = valset;
    
    group = group+1;
    j = j + time_shift;
end

    % make last set -- decide if you want to throw out or adjust this set
    try
        trainset = train(j:j+size_train_set, :);
        valset = train(j+size_train_set+1+set_shift:end, :);
    
        trainDataPartition{group} = trainset;
        valDataPartition{group} = valset;
    catch
        disp('No more sets found')
    end

%%% Optional: force stratification
revised_trainDataPartition = {};
revised_valDataPartition = {};

for i = 1:length(trainDataPartition)
    trainset = trainDataPartition{i};
    valset = valDataPartition{i};
    
    disp([num2str(size(trainset,1)),' ', num2str(size(valset,1))])
    records = table2array(trainset(:,2)); % label index
    records_val = table2array(valset(:,2));
    
    %%%%%%%%%%%%%%%%%%%%%% FOR TRAINING SET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    %%%%%%%%%%%%%%%%%% FOR VALIDATION SET %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if sum(records_val == 1) == 0 || sum(records_val == 0) == 0
        continue
    elseif sum(records_val == 1) > sum(records_val == 0)
        while sum(records_val == 1) >= 1.3 * sum(records_val == 0)
            r = ceil(rand(1) * size(valset, 1));
            if records_val(r) == 1;
                valset(r,:) = [];
                records_val(r) = [];
            end
        end
        revised_valDataPartition{i} = valset;
    else
        while sum(records_val == 1) <= 1.3 * sum(records_val == 0)
            r = ceil(rand(1) * size(valset, 1));
            if records_val(r) == 0
                valset(r,:) = [];
                records_val(r) = [];
            end
        end
        revised_valDataPartition{i} = valset;
    end
    
    
end

trainDataPartition = revised_trainDataPartition;
valDataPartition = revised_valDataPartition;
group = length(revised_trainDataPartition)
end