%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Display Calc Value
%%%%
%%%% Date: 6/5/2019
%%%%
%%%% Purpose: An example wrapper for CalcValue.
%%%%  After you predict labels, it evaluates the value of your
%%%% assessments compared to the Buy and Hold Strategy and a random
%%%% strategy
%%%%
%%%%
%%%% Inputs: resultData, random_toggle
%%%%     - resultData: [cell] output from SVM.m
%%%%       (You can run SVM_Simple for a quick resultData e.g.)
%%%%     - random_toggle: [boolean] whether or not you want the random
%%%%     function on
%%%%
%%%%
%%%% Author: Elisa Warner
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


vals = [];
for i = 1:20
    vals = [vals; calcValue(resultData, true)];
end

[stratnum, hold] = calcValue(resultData,false)

disp(['With Method: ', num2str(stratnum)])
disp(['Random: ', num2str(mean(vals))])
disp(['With Buy and Hold Strategy: ', num2str(hold)])

