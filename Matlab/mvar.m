function variance = mvar(m)

variance = mean(abs(m - (sum(sum(m)) / numel(m))) .^ 2);
variance = mean(variance);

end