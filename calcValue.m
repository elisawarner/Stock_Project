%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Date: 6/5/2019
%%% Use: Converts stock prediction results into a monetary value
%%% Author: Elisa Warner
%%%%
%%%% Purpose: After you predict labels, it evaluates the value of your
%%%% assessments compared to the Buy and Hold Strategy and a random
%%%% strategy
%%%%
%%%%
%%%% Inputs: resultData, random_toggle
%%%%     - resultData: [cell] output from SVM.m
%%%%     - random_toggle: [boolean] whether or not you want the random
%%%%     function on
%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [points_strategy, points_hold] = calcValue(resultData,RANDOM_TOGGLE)

t = readtable('Labels_RUA.csv');
startValue = t(t.Date == resultData{1}.Date(1) + years(2000), :).RUAClose;

points =  - startValue;
randpoints =  - startValue;
numStock = 1;

for i = 1:length(resultData)
    labelSet = resultData{i};
    
    for idx = 1:size(labelSet, 1)
        labelDate = labelSet.Date(idx) + years(2000); % first column is date
        
        row = t(t.Date == labelDate, :);
        RUA = row.RUAClose;
        FutureRUA = row.FutureRUA;
        if RANDOM_TOGGLE == false
            label = labelSet.predLabel(idx);
        else
            label = round(rand(1));
        end
        
        if label == 1 % buy now, sell next month
            points = points - RUA + FutureRUA;
        else % sell now, buy next month
            points = points + RUA - FutureRUA;
            
            if idx == 1 && i == 1
                numStock = numStock - 1
            end
        end
        if RANDOM_TOGGLE == false
            accuracy = sum(resultData{i}.predLabel == resultData{i}.Label) / size(resultData{i},1)
        end
    end
end
numStock;
points_strategy = points + (FutureRUA * numStock);
points_hold = - startValue + (FutureRUA);
end