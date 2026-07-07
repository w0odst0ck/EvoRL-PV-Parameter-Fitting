% 计算最小值、均值、标准差、最大值
min_value = min(Best_score);
mean_value = mean(Best_score);
std_dev = std(Best_score);
max_value = max(Best_score);

% 打印结果
fprintf("最小值: %.15f\n", min_value);
fprintf("最大值: %.15f\n", max_value);
fprintf("均值: %.15f\n", mean_value);
fprintf("标准差: %.15f\n", std_dev);