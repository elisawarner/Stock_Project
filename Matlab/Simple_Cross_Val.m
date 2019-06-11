t = readtable('Features_v1.csv');
train = t(1:4760,:); % the rest is holdout
cvFolds = 5

date = train.Date;
cvIdx = crossvalind('KFold', date, 5);

trainDataPartition = cell(1, cvFolds);
valDataPartition = cell(1, cvFolds);

for j = 1:cvFolds
    trainset = [];
    valset = [];
    
    for i = 1:size(train, 1)
        record = train(i,:);
        if cvIdx(i) == j
            valset = [valset; record];
        else
            trainset = [trainset; record];
        end
    end
    
    trainDataPartition{j} = trainset;
    valDataPartition{j} = valset;
end