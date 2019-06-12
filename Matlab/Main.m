% -Description: This m-file is used in ARSS project to load EHR data,
% create train and test data sets, train an SVMp+ mixture model and test
% the results.
% -Author: Elyas Sabeti, Joshua Drew
% -Date: starte in 2018
% -Project: ARDS
% -Note: This code should be run Window. For usage by other researchers or
% on other machines, only "Config" should be changed.
% -General Comments: This script provides an SMO-style solver for
% SVM+ problems. It is based on the two papers by Pechyony et al.

clear all;
keepVariables = {'AUC_list','trainDataPartition','newTrainDataPartition','valDataPartition', 'gamma_list', 'g_idx', 'Cs_idx', 'C', 'gamma', 'Cs_list', 'Kernel', 'Method','rho','tau','kappa','max_rounds', 'grid', 'grid_std','f', 'keepVariables'}
load('Stock_vals_Label1.mat')
Cs_list = [.1, .4, .8, 1, 2, 4, 6, 8, 10];
gamma_list = [1,2,3,4,5,6,7,8,9,10,15,20];
grid = [];
grid_std = [];
waitbar_f = waitbar(0)

for Cs_idx = 1:length(Cs_list)
    for g_idx = 1:length(gamma_list)
        
        % Method Options: SVM, SVM+, SVMp+
        Method = 'SVMp+';
        Kernel = 'Gaussian';
        gamma = gamma_list(g_idx); %originally 1
        C = 4;
        Cs = Cs_list(Cs_idx);
        %Cs = 0.9;
        rho = 1;
        if isequal(Method,'SVMp+')
            rCs = rho*Cs;
        else
            rCs = C;
        end
        tau = 0; % cosine of desired minimal angle 0.14
        kappa = 0; % minimum distance to the contraint boundaries
        max_rounds = 1e7; % maximum rounds until the algorithm terminates
        rng(1);
        
        % undersample EHR data
        %Config;
        %load('../../Test_train');
        %train = table2array(train)
        %test = table2array(test)
        %bins_split_on_ARDS;
        
        % sort data set based on chest x-ray results
        %[~,ind] = sort(bin_train(:,32), 'descend');
        %bin_train = bin_train(ind,:);
        % selecting label, regular and privileged features for train data
        AUC_list = [];
        resultData = {};
        
        for fold_idx = 1:length(newTrainDataPartition)
            progress = fold_idx * g_idx * Cs_idx;
            total = length(newTrainDataPartition) * length(gamma_list) * length(Cs_list);
            waitbar(progress/total, waitbar_f, ['Progress: ', num2str(round(progress/total * 100)), '% Complete'])
            clearvars -except AUC_list fold_idx ...
                trainDataPartition newTrainDataPartition ...
                valDataPartition gamma_list g_idx Cs_idx rCs Cs C gamma ...
                Cs_list Kernel Method rho tau kappa max_rounds ...
                grid grid_std waitbar_f keepVariables;
            fold = newTrainDataPartition{1,fold_idx};
            fold(:, [1 16 17]) = [];
            fold = table2array(fold);
            x = fold(:,2:14); % train data
            Y = fold(:,1); % train labels
            Y(Y == 0) = -1; % change labels
            x_p = x(:,14:end); % privileged data
            
            % selecting label and regular features for test data
            valfold = valDataPartition{1,fold_idx};
            valfold(:, 1) = [];
            valfold = table2array(valfold);
            test_data = valfold(:, 2:end); % test data
            test_labels = valfold(:,1); % test labels
            test_labels(test_labels == 0) = -1;
            
            % normalizing data
            x_p = x_p/8;
            x_max = max(x);
            x_max(x_max==0)=1;
            x = x./x_max;
            test_data = test_data./x_max;
            
            % privileged information with value "0" means it is not provided
            x_p(x_p == 0) = [];
            
            % SVM does not require privileged information
            if isequal(Method,'SVM')
                x_p = [];
            end
            
            % calculate Kernels
            if isequal(Kernel,'Gaussian')
                [x_times, xp_times, xy_times] = get_kernel_gaussian(x, x_p, test_data);
            elseif isequal(Kernel,'Linear')
                [x_times, xp_times, xy_times] = get_kernel(x, x_p, test_data);
            end
            
            % ask Elyas about this
            ending_count = 0;
            
            % train the model
            TrainMixtureModel;
            AUC_list = [AUC_list; test_AUC];
            
            
            resultData{fold_idx} = table(valDataPartition{1,fold_idx}.Dates, test_labels, test_results);
            resultData{fold_idx}.Properties.VariableNames = {'Date', 'predLabel', 'Label'}
        end
        
        grid(Cs_idx, g_idx) = mean(AUC_list);
        grid_std(Cs_idx, g_idx) = std(AUC_list);    
    end
end

AUC_list
figure;
heatmap(grid, 'Colormap', parula(3), 'ColorbarVisible', 'on', 'XLabel', 'Gamma', 'YLabel', 'C')
title('Validation Set')


figure;
heatmap(grid_std, 'Colormap', winter, 'ColorbarVisible', 'on')
title('Standard Deviation of Validation')
