function deal_data(algorithm_name, benchmark, cell_num_list, case_index_list, setup_factors, raw_data_path, dealed_data_path, trend_length)
%DEAL_DATA Deal data obtained by experiments on one algorithm
% Input: 
%   algorithm_name: name of algorithm
%   benchmark_path: path of benchmark instances
%   benchmark: names of benchmark instances
%   cell_num_list: list of cell numbers to generated instances
%   case_index_list: list of indices of instances to be tested.
%   setup_factors: factors used to generated setup time
%   raw_data_path: path of raw data
%   dealed_data_path: path to save dealed data
%   trend_length: number of samples in a trend
% Save file:
%   This script will save dealed_data in two .csv files in
%       dealed_data_path. 
%           'aggregated_data.csv': storing averaged makespan, best makespan, 
%               worst makespan and std among the repeated runs, as well as algorithm, 
%               instance, number of cells and setup_time factor.
%           'convergence_trends.csv': storing averaged convergence trends
%               among the repeated runs, as well as algorithm, instance, 
%               number of cells and setup_time factor.

% check and reformat dealed_data_path
if ~strcmp(dealed_data_path(end), '/')
    dealed_data_path = [dealed_data_path, '/'];
end
if ~isfolder(dealed_data_path)
    mkdir(dealed_data_path)
end

% store aggregated results and convergence trends in a file seperately
raw_results = struct('algorithm',{},'instance',{},'cell_num',{},...
    'st_factor',{}, 'repeat_num', {}, 'cost', {});
aggregated_results = struct('algorithm',{},'instance',{},'cell_num',{},...
    'st_factor',{},'mean_cost',{},'best_cost',{},'worst_cost',{},'std',{});
convergence_trends = struct('algorithm',{},'instance',{},'cell_num',{},...
    'st_factor',{},'trend',{});

test_index = 0;
raw_index = 0;
for cell_num = cell_num_list
    for case_i = case_index_list
        for factor = setup_factors
            test_index = test_index + 1;
            % load raw data
            save_name = [algorithm_name, '_', benchmark{case_i}(1:end-4), '_', num2str(cell_num), '_', num2str(factor), '.mat'];
            % load results
            load([raw_data_path, save_name]);
            % extract cost and trends
            cost_list = zeros(1, length(results));
            trend_list = zeros(length(results), trend_length);
            for repeat_index = 1:length(results)
                raw_index = raw_index + 1;
                raw_results(raw_index).repeat_num = repeat_index;
                raw_results(raw_index).algorithm = algorithm_name;
                raw_results(raw_index).instance = benchmark{case_i}(1:end-4);
                raw_results(raw_index).cell_num = cell_num;
                raw_results(raw_index).st_factor = factor;
                raw_results(raw_index).cost = results{repeat_index}.cost;
                cost_list(repeat_index) = results{repeat_index}.cost;
                raw_trend = results{repeat_index}.trend;
                sample_index = round(linspace(1,length(raw_trend), trend_length));
                trend_list(repeat_index,:) = raw_trend(sample_index);
            end
            % add results into aggregated results
            aggregated_results(test_index).algorithm = algorithm_name;
            aggregated_results(test_index).instance = benchmark{case_i}(1:end-4);
            aggregated_results(test_index).cell_num = cell_num;
            aggregated_results(test_index).st_factor = factor;
            aggregated_results(test_index).mean_cost = mean(cost_list);
            aggregated_results(test_index).best_cost = min(cost_list);
            aggregated_results(test_index).worst_cost = max(cost_list);
            aggregated_results(test_index).std = std(cost_list);
            % add results into convergence trends
            convergence_trends(test_index).algorithm = algorithm_name;
            convergence_trends(test_index).instance = benchmark{case_i}(1:end-4);
            convergence_trends(test_index).cell_num = cell_num;
            convergence_trends(test_index).st_factor = factor;
            convergence_trends(test_index).trend = mean(trend_list, 1);
        end
    end
end
writetable(struct2table(aggregated_results), [dealed_data_path, 'aggregated_results.csv'])
writetable(struct2table(convergence_trends), [dealed_data_path, 'convergence_trends.csv'])
writetable(struct2table(raw_results), [dealed_data_path, 'raw_results.csv'])
end

