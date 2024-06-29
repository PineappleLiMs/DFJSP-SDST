function[makespan, SS, critical_cell] = dfjsp_setup(SS, data)
% process = NaN([5 3 3 3]); % NaN([job_num mac_num max_op cell_num]);
% process(1, :, :, 1) = [2, 1, 3; 3, 5, NaN; 3, 3, 2]';
% process(2, :, :, 1) = [4, 6, 2; 3, 2, 7; 0, 0, 0]';
% process(3, :, :, 1) = [3, 1, 4; NaN, 3, 4; 4, 4, 2]';
% process(4, :, :, 1) = [5, 4, 5; 0, 0, 0; 0, 0, 0]';
% process(5, :, :, 1) = [NaN, 5, 8; 2, 1, 2; 0, 0, 0]';
% process(1, :, :, 2) = [3, NaN, 2; 3, 3, 3; 2, 1, NaN]';
% process(2, :, :, 2) = [5, 4, 5; 5, 4, 3; 0, 0, 0]';
% process(3, :, :, 2) = [3, 6, 4; 5, 3, 4; NaN, NaN, NaN]';
% process(4, :, :, 2) = [6, 3, 5; 0, 0, 0; 0, 0, 0]';
% process(5, :, :, 2) = [NaN, NaN, NaN; NaN, NaN, NaN; 0, 0, 0]';
% process(1, :, :, 3) = [2, 4, NaN; 3, NaN, NaN; NaN, 3, NaN]';
% process(2, :, :, 3) = [4, 5, NaN; 4, 3, NaN; 0, 0, NaN]';
% process(3, :, :, 3) = [4, 3, NaN; 2, 2, NaN; 2, 3, NaN]';
% process(4, :, :, 3) = [3, 4, NaN; 0, 0, NaN; 0, 0, NaN]';
% process(5, :, :, 3) = [5, 4, NaN; 2, 3, NaN; 0, 0, NaN]';
% SS = [3, 2, 2, 1, 5, 4, 1, 5, 1, 3, 3; 
%       1, 2, 2, 1, 2, 2, 1, 2, 1, 1, 1;
%       3, 2, 3, 1, 3, 3, 2, 1, 3, 2, 1];
process = data.process;
setup = data.setup;
op_num = data.op_num;
cell_mean = data.cell_mean;

[job_num, mac_num, ~, cell_max] = size(process);
operation_set = ones(1, job_num);
% freq = tabulate(SS(1, :));
% if any(freq(:, 2) > op_num)
%     error('More input operations than DFJSP can handle!');
% end

%% job2cell according to cell-load balance criterion and operation2machine according to operation-to-machine assignment
if size(SS, 1) == 1
    SS = [SS; repelem(1, size(SS, 2)); repelem(1, size(SS, 2))];
end
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

% machine_capability = zeros(mac_num, cell_max);
% for i_mac = 1:mac_num
%     for j_cell = 1:cell_max
% %         machine_capability(i_mac, j_cell) = sum(~isnan(process(unique(SS(1, SS(2,:)==j_cell)), i_mac, :, j_cell)), "all");
%         machine_capability(i_mac, j_cell) = sum(process(unique(SS(1, SS(2,:)==j_cell)), i_mac, :, j_cell), "all", "omitnan");
%     end
% end
% machine_capability = reshape(machine_capability, [mac_num*cell_max, 1]);

%% operation-to-machine according to machine-load-balance criterion
machine_set_full = zeros(mac_num, cell_max);
for i_cell = 1:cell_max
    clear partial_set_before partial_set_after
    
    if ~any(SS(2, :)==i_cell)
        break
    end
    SS_partial = SS(:, SS(2, :)==i_cell);
    
    machine_set = zeros(mac_num, 1);
    machine_time = zeros(mac_num, 1);
    operation_time = NaN(1, job_num);
    operation_set = NaN(1, job_num);
    operation_time(unique(SS_partial(1,:))) = 0;
    operation_set(unique(SS_partial(1,:))) = 1;
    
    machine_candidate = process(SS_partial(1, 1), :, operation_set(SS_partial(1, 1)), i_cell);
    machine_time(:, 1) = reshape(machine_candidate, [mac_num, 1]);
    machine_select = machine_time(:, 1) + ...
        max(reshape(machine_set, [mac_num, 1]), ...
        repelem(operation_time(SS_partial(1, 1)), mac_num)');
    mac_min = min(machine_select);
    mac_index = find(machine_select == mac_min);
    for i_mac = 1:length(mac_index)
        setup_index = zeros(2, mac_num);
        increase_time = max(machine_set(mac_index(i_mac), 1), operation_time(SS_partial(1, 1))) + ....
            machine_time(mac_index(i_mac), 1);
        operation_time(SS_partial(1, 1)) = increase_time;
        machine_set(mac_index(i_mac), 1) = increase_time;
        SS_partial(3, 1) = mac_index(i_mac);
        
        setup_index(:, mac_index(i_mac)) = [SS_partial(1, 1); operation_set(SS_partial(1, 1))];
        
        partial_set_before.SS{i_mac} = SS_partial;
        partial_set_before.machine_set{i_mac} = machine_set;
        partial_set_before.operation_time{i_mac} = operation_time;  
        
        partial_set_before.setup_index{i_mac} = setup_index;
    end
    operation_set(SS_partial(1, 1)) = operation_set(SS_partial(1, 1)) + 1;
    
    for i_op = 2:size(SS_partial, 2)
        machine_candidate = process(SS_partial(1, i_op), :, operation_set(SS_partial(1, i_op)), i_cell);
        machine_time(:, 1) = reshape(machine_candidate, [mac_num, 1]);
        
        opT = [];
        mac_set = 0;
        for j_set = 1:size(partial_set_before.SS, 2)
            machine_set = partial_set_before.machine_set{j_set};
            operation_time = partial_set_before.operation_time{j_set};
                        
            machine_select = machine_time(:, 1) + ...
                max(reshape(machine_set, [mac_num, 1]), ...
                repelem(operation_time(SS_partial(1, i_op)), mac_num)');
            mac_min = min(machine_select);
            mac_index = find(machine_select == mac_min);
            
            for i_mac = 1:length(mac_index)
                SS_partial = partial_set_before.SS{j_set};
                setup_index = partial_set_before.setup_index{j_set};
%                 machine_set
%                 operation_time 
%                 sum(op_num(1:(SS_partial(1, i_op)-1)))+operation_set(SS_partial(1, i_op))
%                 sum(op_num(1:(setup_index(1, mac_index(i_mac))-1)))+setup_index(2, mac_index(i_mac))
                
                setuptime = 0;
                if setup_index(1, mac_index(i_mac)) ~= 0
                setuptime = setup(sum(op_num(1:(SS_partial(1, i_op)-1)))+operation_set(SS_partial(1, i_op)), ...
                    sum(op_num(1:(setup_index(1, mac_index(i_mac))-1)))+setup_index(2, mac_index(i_mac)), i_cell);
                end
                
                increase_time = max(machine_set(mac_index(i_mac), 1) + setuptime, ...
                    operation_time(SS_partial(1, i_op))) + ....
                    machine_time(mac_index(i_mac), 1);
                operation_time(SS_partial(1, i_op)) = increase_time;
                machine_set(mac_index(i_mac), 1) = increase_time;
                SS_partial(3, i_op) = mac_index(i_mac);
                
                setup_index(:, SS_partial(3, i_op)) = [SS_partial(1, i_op); operation_set(SS_partial(1, i_op))];
                
                partial_set_after.SS{mac_set + i_mac} = SS_partial;
                partial_set_after.machine_set{mac_set + i_mac} = machine_set;
                partial_set_after.operation_time{mac_set + i_mac} = operation_time;
                
                partial_set_after.setup_index{mac_set + i_mac} = setup_index;
                
                opT = [opT operation_time(SS_partial(1, i_op))];
            end
            mac_set = length(mac_index) + mac_set;
        end
        opT_min = min(opT);
        partial_set_before.SS = partial_set_after.SS(opT == opT_min);
        partial_set_before.machine_set = partial_set_after.machine_set(opT == opT_min);
        partial_set_before.operation_time = partial_set_after.operation_time(opT == opT_min);
%         partial_set_before.operation_time{1}
        
        partial_set_before.setup_index = partial_set_after.setup_index(opT == opT_min);
        
        operation_set(SS_partial(1, i_op)) = operation_set(SS_partial(1, i_op)) + 1;
        
    end
    machine_set_full(:, i_cell) = partial_set_before.machine_set{1};
    SS(3,SS(2, :) == i_cell) = partial_set_before.SS{1}(3, :);
end

[makespan, critical_cell] = max(max(machine_set_full));
SS = SS(1, :);
end
