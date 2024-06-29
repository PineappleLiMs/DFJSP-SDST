function[process] = data2process(data, cell_num)
% cell_num = 2;
% data = readtable(['DFJSP/la17.fjs'],'FileType','text', 'ReadVariableNames', false, 'Delimiter', ',');
char_cell = num2cell(str2num(char(table2array(data(1,1)))));
[job_num,mac_num,~] = deal(char_cell{:});
op_num = zeros([job_num 1]);
for i_job = 1:job_num
    job_data = str2num(char(table2array(data(i_job+1,1))));
    op_num(i_job) = job_data(1);
end
max_op = max(op_num);
process = NaN([job_num mac_num max_op cell_num]);
for i_job = 1:job_num
    job_data = str2num(char(table2array(data(i_job+1,1))));
    k = 2;
    for j_op = 1:op_num(i_job)
        flex_num = job_data(k);
        k = k + 1;
        for i_flex = 1:flex_num
            process(i_job, job_data(k), j_op, :) = job_data(k+1);
            k = k + 2;
        end
        if op_num(i_job) < max_op
            process(i_job, :, (j_op + 1):max_op, :) = 0;
            break
        end
    end
end
end
