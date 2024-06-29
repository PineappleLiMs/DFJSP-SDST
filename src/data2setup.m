function[setup, op_num] = data2setup(data, cell_num)
% cell_num = 2;
% data = readtable(['DFJSP/setup_la17.fjs'],'FileType','text', 'ReadVariableNames', false, 'Delimiter', ',');
line1 = str2num(char(table2array(data(1,1))));
job_num = line1(1);
op_num = line1(2:end);
max_op = max(op_num);
setdata = [];
for i_job = 1:sum(op_num)
    setdata = [setdata; str2num(char(table2array(data(i_job+1,1))))];
end
setup = zeros([sum(op_num) sum(op_num) cell_num]);

for i_cell = 1:cell_num
    setup(:, :, i_cell) = setdata;
end
end
