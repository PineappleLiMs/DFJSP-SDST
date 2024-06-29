function [end_solution, end_cost, best_record, trend] = ig_insertion_neighborhood(start_solution, start_cost, data, best_record, other_parameters)
%IG_INSERTION_NEIGHBORHOOD Local search used in IG algorithms
% Input:
%   start_solution: the start solution of local search (vector)
%   start_cost: makespan of the start solution (int)
%   data: struct of DFJSP instance
%   best_record: struct of best solution ever searched, including
%       best_record.solution, best_record.cost.
%   other_parameters: a struct containing other parameters needed for
%       certian configurations, including:
%           until_no_improvement: if local search will continue until no
%               improvement, or stop after the first loop. (logical)
% Output:
%   end_solution: the final solution after local search (vector)
%   end_cost: makespan of end_solution (int)
%   best_record: updated best_record
%   trend: record of best cost during ig_insertion_neighborhood

% initial parameters
if ~ismember('ref_best', fieldnames(other_parameters))
    other_parameters.ref_best = false;
end
if ~ismember('until_no_improvement', fieldnames(other_parameters))
    other_parameters.until_no_improvement = true;
end
if ~ismember('use_tie_breaking', fieldnames(other_parameters))
    other_parameters.use_tie_breaking = false;
end

improve = true;
end_solution = start_solution;
end_cost = start_cost;
trend = [];
while improve
    improve = false;
    % generate order for destruction
    if other_parameters.ref_best
        not_tested = best_record.solution;
    else
        not_tested = start_solution(randperm(length(start_solution)));
    end
    
    solution_tem = end_solution;
    appear_time = zeros(1, size(data.process,1));
    for removed_job = not_tested
        % record the appearance time of removed_job in solution_tem
        appear_time(removed_job) = appear_time(removed_job) + 1;
        % remove selected job
        removed_indices = find(solution_tem == removed_job);
        remove_index = removed_indices(appear_time(removed_job));
        solution_tem(remove_index) = [];
        % add removed job into all positions and insert it into the best
        [solution_tem,~,cost_tem] = insert_best_position(solution_tem, data, removed_job);
        % update solution if better solution is searched
        if cost_tem < end_cost
            end_solution = solution_tem;
            end_cost = cost_tem;
            improve = true;
            if cost_tem < best_record.cost
                best_record.solution = solution_tem;
                best_record.cost = cost_tem;
            end
        end
        trend = [trend, best_record.cost];
        
        if ~other_parameters.until_no_improvement
            break
        end
    end
end

