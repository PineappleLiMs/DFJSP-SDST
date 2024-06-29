function[SS] = job2cell(SS, data)
process = data.process;
cell_mean = data.cell_mean;
[job_num, ~, ~, cell_max] = size(process);

if size(SS, 1) == 1
    SS = [SS; repelem(1, size(SS, 2))];
end

operation_set = ones(1, job_num);
cell_time = zeros(1, cell_max);
for i_op = 1:size(SS, 2)
    if operation_set(SS(1, i_op)) == 1
        [add_time, cell_index] = min(cell_time + cell_mean(SS(1, i_op), :));
        cell_time(cell_index) = cell_time(cell_index) + add_time;
        SS(2, SS(1, :) == SS(1, i_op)) = cell_index;
        operation_set(SS(1, i_op)) = operation_set(SS(1, i_op)) + 1;
    end
    if all(operation_set > 1)
        break
    end
end