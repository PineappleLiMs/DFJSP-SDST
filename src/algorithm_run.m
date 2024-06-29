function algorithm_run(algorithm_name, benchmark_path, benchmark, cell_num_list, case_index_list, setup_factors, run_settings, save_path)
%ALGORITHM_RUN Main function for repeated run on one algorithm
% Input: 
%   algorithm_name: name of algorithm
%   benchmark_path: path of benchmark instances
%   benchmark: names of benchmark instances
%   cell_num_list: list of cell numbers to generated instances
%   case_index_list: list of indices of instances to be tested.
%   setup_factors: factors used to generated setup time
%   run_settings: a struct containing settings of the run, including
%           repeat_num: number of repeated times on an instance
%           max_time_parameter: parameter controlling the maximum CPU time
%   save_path: path to save results
% Save file:
%   results of repeated runs. It is a (1*repeat_num) cell, each elements stores 
%       the result by one run. The elements are structs containing 
%           solution: final solution obtained in the run
%           cost: makespan of final solution
%           trend: convergence trends of the run
%           used_time: real cpu time used by the run

% check the format of benchamrk_path and save_path
if strcmp(benchmark_path(end), '/')
    benchmark_path(end) = [];
end
if ~strcmp(save_path(end), '/')
    save_path = [save_path, '/'];
end

% check whether save_path exists. If not, create it
if ~isfolder(save_path)
    mkdir(save_path)
end

for cell_num = cell_num_list
    for case_i = case_index_list
        for factor = setup_factors
            %% load instance
            filename = [benchmark_path, '/', benchmark{case_i}];
            alldata = readtable(filename, 'FileType', 'text', 'ReadVariableNames', false, 'Delimiter', ',');
            setupfile = [benchmark_path, '/', 'setup_', num2str(factor), '_', benchmark{case_i}];
            setupdata = readtable(setupfile, 'FileType', 'text', 'ReadVariableNames', false, 'Delimiter', ',');

            process = data2process(alldata, cell_num);
            [setup, op_num] = data2setup(setupdata, cell_num);
            [job_num, ~, max_op, cell_max] = size(process);
            cell_mean = zeros(job_num, cell_max);
            for i_cell = 1:cell_max
                for i_job = 1:job_num
                    for j_op = 1:max_op
                        cell_mean(i_job, i_cell) = cell_mean(i_job, i_cell) + mean(process(i_job, :, j_op, i_cell), "omitnan");
                    end
                end
            end

            data1.process = process;
            data1.setup = setup;
            data1.op_num = op_num;
            data1.cell_mean = cell_mean;

            %% set terminal condition
            max_time = run_settings.max_time_parameter * size(data1.process,3) * size(data1.process,1);

            %% run given algorithm
            switch algorithm_name
                case {'ss', 'SS'}
                    % case: scatter search
                    % parameter settings of scatter search
                    maxb = 12;
                    max_distance = 0.5;
                    t0SA = mean(data1.process, 1:ndims(data1.process), "omitnan")/10;
                    local_search_method = 2; % set as 'insert'
                    results = cell(1, run_settings.repeat_num);
                    parfor repeat_index = 1:run_settings.repeat_num
                        [final_best_value, final_best_solution,~,cput,~,trend] = nwk_ss(maxb,data1,max_time,max_distance,t0SA,local_search_method);
                        if iscell(final_best_solution)
                            final_best_solution = final_best_solution{1};
                        end
                        result = struct('solution', final_best_solution, 'cost', final_best_value,...
                            'time_used', cput, 'trend', trend);
                        results{repeat_index} = result;
                    end
                case {'sa', 'SA'}
                    % case: simulated annealing
                    % parameter settings of sa
                    maxb = 12;
                    max_distance = 0.5;
                    t0SA = mean(data1.process, 1:ndims(data1.process), "omitnan")/10;
                    local_search_method = 2; % set as 'insert'
                    results = cell(1, run_settings.repeat_num);
                    parfor repeat_index = 1:run_settings.repeat_num
                        [final_best_value, final_best_solution,~,cput,~,trend] = nwk_sa(maxb,data1,max_time,max_distance,t0SA,local_search_method);
                        result = struct('solution', final_best_solution, 'cost', final_best_value,...
                            'time_used', cput, 'trend', trend);
                        results{repeat_index} = result;
                    end
                case {'hh-bs-sa', 'HH-BS-SA'}
                    % case: BS-SA
                    MaxLLH = 3;
                    t0SA = mean(data1.process, 1:ndims(data1.process), "omitnan")/10;
                    results = cell(1, run_settings.repeat_num);
                    parfor repeat_index = 1:run_settings.repeat_num
                        [final_best_value, final_best_solution,~,cput,trend,~] = nwk_HH_BS_SA(data1,max_time,MaxLLH, t0SA);
                        result = struct('solution', final_best_solution, 'cost', final_best_value,...
                            'time_used', cput, 'trend', trend);
                        results{repeat_index} = result;
                    end
                case {'hh-rpd-sa', 'HH-RPD-SA'}
                    % RPD-AM
                    MaxLLH = 3;
                    t0SA = mean(data1.process, 1:ndims(data1.process), "omitnan")/10;
                    results = cell(1, run_settings.repeat_num);
                    parfor repeat_index = 1:run_settings.repeat_num
                        [final_best_value, final_best_solution,~,cput,trend,~] = nwk_HH_RPD_SA(data1,max_time,MaxLLH, t0SA);
                        result = struct('solution', final_best_solution, 'cost', final_best_value,...
                            'time_used', cput, 'trend', trend);
                        results{repeat_index} = result;
                    end
                case {'qig', 'QIG'}
                    % case: Q-learning based iterated greedy
                    % parameter settings for QIG
                    qig_parameters = struct('epsilon_greedy', 0.8, ...
                        'operator_list', [1,2,3], ...
                        'episode_size', 6, ...
                        'epsilon_greedy_decay', 0.996, ...
                        'learning_rate', 0.8, ...
                        'alpha_learning', 0.6, ...
                        'use_tie_breaking', false);
                    local_search_parameters = struct('temperature_parameter', 0.7, ...
                        'use_tie_breaking', false);
                    results = cell(1, run_settings.repeat_num);
                    parfor repeat_index = 1:run_settings.repeat_num
                        [result, ~] = algorithm_qig(data1, max_time, qig_parameters,...
                            local_search_parameters);
                        results{repeat_index} = result;
                    end
                case {'IG1', 'IG2', 'IG3', 'IG4', 'IG5', 'IG6'}
                    % case: iterated greedy with fixed disturbance degree
                    % parameter settings for IG
                    d = str2double(algorithm_name(end));
                    local_search_parameters = struct('temperature_parameter', 0.7, ...
                        'use_tie_breaking', false);
                    results = cell(1, run_settings.repeat_num);
                    parfor repeat_index = 1:run_settings.repeat_num
                        result = algorithm_ig(data1, max_time, d,...
                            local_search_parameters);
                        results{repeat_index} = result;
                    end
            end
            %% save results in given path
            save_name = [algorithm_name, '_', benchmark{case_i}(1:end-4), '_', num2str(cell_num), '_', num2str(factor), '.mat'];
            save([save_path, save_name], "results")
            disp(save_name(1:end-4))
        end
    end
end
end

