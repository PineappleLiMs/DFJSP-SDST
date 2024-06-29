function [ini_fitness, ini_solution] = RAER(data, popsize)
% NEH heuristic algorithm for Heterogeneous Distributed Scheduling Problem
% input : data, the property of machines and specimens
%       : popsize, the amount of initial solutions
% output: cost, the makespan of proposed solution
%         all_solution, the final feasible solution

ini_fitness = zeros([popsize 1]);
% ini_critical_cell = zeros([popsize 1]);
ini_solution = cell(popsize, 1);
[job_num, ~, op_num, ~] = size(data.process);
n = job_num * op_num;
for i_pop = 1:popsize
    solution = repelem(1:job_num, op_num);
    solution = solution(randperm(job_num*op_num));
    % solution = [solution(randperm(job_num*op_num)); ones(1, n); ones(1, n)];
    
    p = 1;
    all_solution = solution(:, 1);
    while p < n
        p = p + 1;
        inserting_item = solution(:, p);
        [all_solution,~,cost] = insert_best_position(all_solution, data,...
            inserting_item);
    end
%     all_solution = job2cell(all_solution, data);
    ini_fitness(i_pop) = cost;
    % [~, all_solution, ~] = dfjsp_setup(all_solution, data);
    ini_solution{i_pop} = all_solution;
%     ini_critical_cell(i_pop) = critical_cell;
end
end