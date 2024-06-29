function result = algorithm_ig(data, max_time, d, local_search_parameters)
%ALGORITHM_QIG Main function of iteraged greedy algorithm (IG).

% Input
%   data: struct of DFJSP instance
%   max_time: maximum CPU time (float)
%   d: number of operations to be removed in destruction stage (int)
%   local_search_parameters: parameters used for meta-Lamarckian local search. It is a
%       struct containing the following fields:
%           temperature_parameter: parameter determine the temperature. Set
%               to be 0.7 in original paper.
%           use_tie_breaking: whether or not use tie-breaking in local
%               search. Set ot be true in original paper, but should be false in our DFJSP.
% Output:
%   results: cell of results, its each element contains the result for a
%       instnace. If only one single instance is inputed, it is still a
%       struct. Result contains the following fields:
%           cost: best makespan searched through algorithm (int)
%           solution: best solution searched through algorithm (vector)
%           trend: convergence trends (vector)
%           time_used: actual used CPU time (float)

% initialize parameters used in local seach
other_parameters = struct('use_tie_breaking', local_search_parameters.use_tie_breaking, 'ref_best', false, 'until_no_improvement', true);
%% Initialization: generate an initial solution via NEH
start_time = cputime;
dimension = size(data.process, 1);
% popsize = max(20,(dimension*0.05));
popsize = 6;
[ini_fitness,ini_solution] = RAER(data, popsize);
[cost,b] = min(ini_fitness);
solution = ini_solution{b};
trend = cost;

% local search on initial solution
best_record = struct('solution', solution, 'cost', cost);
[solution, cost, best_record, trend_tem] = ig_insertion_neighborhood(solution, cost,...
    data, best_record, other_parameters);
result = struct('solution', best_record.solution, 'cost', best_record.cost,...
        'trend', [trend, trend_tem]);
temperature = local_search_parameters.temperature_parameter * mean(data.process, 1:ndims(data.process), "omitnan")/10;
%% iteration
num_iteration = 0;
time_used = cputime - start_time;
while time_used < max_time
    num_iteration = num_iteration + 1;
    remove_jobs_index = randperm(length(solution), d);
    partial_solution = [];
    for job_index = 1:length(solution)
        if ~ismember(job_index, remove_jobs_index)
            partial_solution = [partial_solution, solution(job_index)];
        end
    end
    % local search on partial solution
    partial_cost = dfjsp_setup(partial_solution, data);
    best_record_tem = struct('solution', partial_solution, 'cost', partial_cost);
    [partial_solution, ~, ~, ~] = ig_insertion_neighborhood(partial_solution,...
        partial_cost, data, best_record_tem, other_parameters);
    % construction
    new_solution = partial_solution;
    for job_index = remove_jobs_index
        inserting_job = solution(job_index);
        [new_solution, ~, new_cost] = insert_best_position(new_solution,...
            data,inserting_job);
    end
    if new_cost < result.cost
        result.cost = new_cost;
        result.solution = new_solution;
    end
    % local search on new solution
    best_record = struct('solution', solution, 'cost', cost);
    [new_solution, new_cost, best_record, trend_tem] = ...
        ig_insertion_neighborhood(new_solution, new_cost,...
        data, best_record, other_parameters);
    result.solution = best_record.solution;
    result.cost = best_record.cost;
    % SA-like acceptance criteria
    if new_cost < cost
        cost = new_cost;
        solution = new_solution;
    else
        if rand < exp(-(new_cost-cost)/temperature)
            cost = new_cost;
            solution = new_solution;
        end
    end
    result.trend = [result.trend, trend_tem];
    time_used = cputime - start_time;
    result.time_used = time_used;
end
end

