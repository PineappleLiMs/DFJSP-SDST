function data = load_instance(benchmark_path,benchmark_name, cell_num, setup_factor)
%LOAD_INSTANCE Load benchmark instance
% Input:
%   benchmark_path: path of benchmark instance
%   benchmark_name: name of instance (should be ended with '.fjs')
%   cell_num: number of cells
%   setup_factor: factor for setup time
% Output:
%   data: data of the instance. It is a struct containing the following
%       fields:
%           process: processing times (4-D matrix)
%           setup: setup time (3-D matrix)
%           op_num: number of operators
%           cell_mean: averaged processing time of a cell

% check and reformat benchmark_path
if strcmp(benchmark_path(end), '/')
    benchmark_path(end) = [];
end
% read instance
filename = [benchmark_path, '/', benchmark_name];
alldata = readtable(filename, 'FileType', 'text', 'ReadVariableNames', false, 'Delimiter', ',');
setupfile = [benchmark_path, '/', 'setup_', num2str(setup_factor), '_', benchmark_name];
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

data.process = process;
data.setup = setup;
data.op_num = op_num;
data.cell_mean = cell_mean;

end

