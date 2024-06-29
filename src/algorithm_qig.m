function [result, other_information] = algorithm_qig(data, max_time, qig_parameters,local_search_parameters)
%ALGORITHM_QIG Main function of Q-learning based iteraged greedy algorithm (QIG).
%Ref: Karimi-Mamaghan, M., Mohammadi, M., Pasdeloup, B., & Meyer, P. (2023). Learning to select operators in meta-heuristics: An integration of Q-learning into the iterated greedy algorithm for the permutation flowshop scheduling problem. European Journal of Operational Research, 304(3), 1296-1330. https://doi.org/https://doi.org/10.1016/j.ejor.2022.03.054 
% The original paper is to solve PFSP. We made some adaption so that it can
% solve DFJSP.

% Input
%   data: struct of DFJSP instance
%   max_time: maximum CPU time (float)
%   qig_parameters: parameters used for QIG. It is a struct containing the
%       following fields：index
%           epsilon_greedy: parameter for epsilon greedy, set to be 0.8 in orignial paper (int)
%           operator_list: list of action operators, i.e., numer of jobs to
%               remove. Set to be [1,2,3] in original paper.
%           episode_size: size of search under one select action. Set to be
%               6 in original paper.
%           epsilon_greedy_decay: decay rate of epsilon greedy parameter.
%               Set to be 0.996 in original paper.
%           learning_rate: learning rate. Set to be 0.8 in original paper.
%           alpha_learning: parameter to update Q matrix. Set to be 0.6 in
%               original paper.
%           use_tie_breaking: whether or not use tie-breaking in
%               construction phase. Set true in original paper, but should
%               be false in our case.
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
%   other_information: cell of results containing important information 
%       obtained during QIG. Including the following fields:
%           action_sequence: actions used in each iteration;
%           state_sequence: states in each iteration;

% initialize parameters used in local seach
other_parameters = struct('use_tie_breaking', local_search_parameters.use_tie_breaking, 'ref_best', false, 'until_no_improvement', true);
% initialize parameters for Q-learning
state = 0;
q_matrix = zeros(2, length(qig_parameters.operator_list));
action_sequence = [];
state_sequence = [];

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
    cost_during_episode = cost;
    best_cost_during_episode = result.cost;
    %% destruction and construction
    % select action based on epsilon greedy
    if rand < qig_parameters.epsilon_greedy
        action_index = randi(length(qig_parameters.operator_list));
    else
        [~,action_index] = max(q_matrix(state+1,:));
    end
    action = qig_parameters.operator_list(action_index);
    action_sequence = [action_sequence, action];
    state_sequence = [state_sequence, state];
    for ep = 1:qig_parameters.episode_size
        % destruction using the selected action
        remove_jobs_index = randperm(length(solution), action);
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
        cost_during_episode(end+1) = cost;
        best_cost_during_episode(end+1) = result.cost;
    end

    %% calculate rewards and update Q matrix
    mins_cur = cost_during_episode(1);
    improvement_num = 0;
    for imp = 1:qig_parameters.episode_size
        if cost_during_episode(imp+1) < mins_cur(end)
            mins_cur = [mins_cur, cost_during_episode(imp+1)];
        end
    end
    mins_best = best_cost_during_episode(1);
    for imp = 1:qig_parameters.episode_size
        if best_cost_during_episode(imp+1) < mins_best(end)
            improvement_num = improvement_num + 1;
            mins_best = [mins_best, best_cost_during_episode(imp+1)];
        end
    end
    DL = (cost_during_episode(1) - mins_cur(end)) / cost_during_episode(1);
    DG = (best_cost_during_episode(1) - mins_best(end)) / result.cost;
    reward = 0.3*max(DL,0) + 0.7*max(DG,0);
    % update Q matrix
    if improvement_num > 0
        new_state = 1;
        q_matrix(state+1, action) = q_matrix(state+1, action) + ...
            qig_parameters.alpha_learning * (reward + qig_parameters.learning_rate*max(q_matrix(new_state+1,:)) ...
            - q_matrix(state+1,action));
        state = new_state;
    else
        state = 0;
        q_matrix(state+1,action) = q_matrix(state+1,action) + ...
            qig_parameters.alpha_learning * (reward - q_matrix(state+1,action));
    end

    % updata parameters for next loop
    qig_parameters.epsilon_greedy = qig_parameters.epsilon_greedy * qig_parameters.epsilon_greedy_decay;
    qig_parameters.learning_rate = qig_parameters.learning_rate * qig_parameters.epsilon_greedy_decay;
    time_used = cputime - start_time;
    result.time_used = time_used;
end

other_information = struct('action_sequence', action_sequence, 'state_sequence', state_sequence);
end
