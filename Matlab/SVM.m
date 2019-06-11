function [grid, grid_train, grid_std, resultData] = SVM(normTrain, normVal)

skip = 2; % changed from 2
grid = [];
grid_train = [];
C_list = [4]; %.1 .2 .3 .4 .5 .6 .7 .8 .9 1 2 3 4 5 6 7 8 9 10];
gamma_list = [1]; % 2 3 4 5 6 7 8 9 10 20]; % 30 40 50 60 70
resultData = {};

for C_idx = 1:length(C_list);
    C = C_list(C_idx);

    for g_idx = 1:length(gamma_list)
        gamma = gamma_list(g_idx);

        %disp(['C: ', num2str(C), ' gamma: ', num2str(gamma)])

        AUC_list = [];
        AUC2_list = [];
        
        for i = 1:size(normTrain,2)
            i;
            try
                t = normTrain{i};
                X = table2array(t(:,skip+1:end));
                
                %X = X(:,skip+1:end);
                Y = normTrain{i}.labels; %labels;
                %Y = abs(Y); % 0 vs rest
                %Y = Y .* (Y > 0); % 1 vs rest
                %Y = Y .* (Y < 0) * -1; % -1 vs rest
                
                t = normVal{i};
                newX = table2array(t(:,skip+1:end));
                %newX = newX(:,skip+1:end);
                newY = normVal{i}.labels; %labels;
               %gamma = 1 / (size(X, 2) * mvar(X));
                disp(['test: ', num2str(sum(newY==1)),' ', num2str(length(newY))])
                disp(['train: ', num2str(sum(Y == 1)),' ', num2str(length(Y))])

                model = fitcsvm(X,Y,'KernelFunction','rbf','KernelScale', gamma,...
                    'BoxConstraint',C,'ClassNames',[0, 1], 'Solver', 'SMO'); %, ...
                %'Verbose',0); % double penalty for false neg
                %model = fitcsvm(X,Y, 'KernelFunction', 'rbf', ...
                %    'OptimizeHyperparameters','auto',...
                %    'HyperparameterOptimizationOptions',...
                %    struct('AcquisitionFunctionName',...
                %    'expected-improvement-plus'))
                %model = fitSVMPosterior(model);
                [labels, score_svm] = predict(model, X);
                
                [Xsvm,Ysvm,Tsvm,AUC2] = perfcurve(Y,labels,1);
                [labels2, score_svm] = predict(model, newX); %resubPredict(model);
                
                resultData{i} = table(normVal{i}.Dates, labels2, newY);
                resultData{i}.Properties.VariableNames = {'Date', 'predLabel', 'Label'}

                [Xsvm,Ysvm,Tsvm,AUC] = perfcurve(newY,labels2,1);
                AUC_list = [AUC_list; AUC];
                disp(AUC)
                AUC2_list = [AUC2_list;AUC2];
            %end
        end
        
        disp(['Validation: ', num2str(mean(AUC_list)), ' Training: ', num2str(mean(AUC2_list))])
        grid(C_idx, g_idx) = mean(AUC_list);
        grid_train(C_idx, g_idx) = mean(AUC2_list);
        grid_std(C_idx, g_idx) = std(AUC_list);
        
    end
    end
end
figure;
heatmap(grid, 'Colormap', parula(3), 'ColorbarVisible', 'on', 'XLabel', 'Gamma', 'YLabel', 'C')
title('Validation Set')

figure;
heatmap(grid_train, 'Colormap', spring, 'ColorbarVisible', 'on', 'XLabel', 'Gamma', 'YLabel', 'C')
title('Training Set')

figure;
heatmap(grid_std, 'Colormap', winter, 'ColorbarVisible', 'on')
title('Standard Deviation of Validation')

end