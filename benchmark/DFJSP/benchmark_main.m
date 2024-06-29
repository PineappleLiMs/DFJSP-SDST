Factor = 25; % 25, 50, 100
benchmark = {...
    'la01.fjs'; 'la02.fjs'; 'la03.fjs'; 'la04.fjs'; ...
    'la05.fjs'; 'la06.fjs'; 'la07.fjs'; 'la08.fjs'; ...
    'la09.fjs'; 'la10.fjs'; 'la11.fjs'; 'la12.fjs'; ...
    'la13.fjs'; 'la14.fjs'; 'la15.fjs'; 'la16.fjs'; ...
    'la17.fjs'; 'la18.fjs'; 'la19.fjs'; 'la20.fjs'; ...
    'mt06.fjs'; ...
    'mt10.fjs'; 'mt20.fjs'...
    };
for case_i = 1:length(benchmark)
    filename = benchmark{case_i};
    data = readtable(filename, 'FileType', 'text', 'ReadVariableNames', false, 'Delimiter', ',');
    char_cell = num2cell(str2num(char(table2array(data(1,1)))));
    [job_num,mac_num,~] = deal(char_cell{:});
    op_num = zeros([1, job_num]);
    for i_job = 1:job_num
        job_data = str2num(char(table2array(data(i_job+1,1))));
        op_num(i_job) = job_data(1);
    end
    line1 = [job_num,op_num];
    
    setup = zeros(sum(op_num), sum(op_num));
    if case_i == 21
        r1 = 10;
    else
        r1 = 99;
    end
    for i_job = 1:(job_num-1)
        for j_job = (i_job+1):job_num
            setup(sum(op_num(1:(i_job-1)))+(1:op_num(i_job)), ...
                sum(op_num(1:(j_job-1)))+(1:op_num(j_job))) = ...
                ceil(rand(op_num(i_job), op_num(j_job))*r1*Factor/100);
            setup(sum(op_num(1:(j_job-1)))+(1:op_num(j_job)), ...
                sum(op_num(1:(i_job-1)))+(1:op_num(i_job))) =  ...
                setup(sum(op_num(1:(i_job-1)))+(1:op_num(i_job)), ...
                sum(op_num(1:(j_job-1)))+(1:op_num(j_job)))';
        end
    end
    
   for i_job = 1:job_num
        for i_op = 1:(op_num(i_job)-1)
            for j_op = (i_op+1):op_num(i_job)
            setup(sum(op_num(1:(i_job-1)))+i_op, ...
                sum(op_num(1:(i_job-1)))+j_op) = ...
                ceil(rand*r1*Factor/100);
            setup(sum(op_num(1:(i_job-1)))+j_op, sum(op_num(1:(i_job-1)))+i_op) =  ...
                setup(sum(op_num(1:(i_job-1)))+i_op, sum(op_num(1:(i_job-1)))+j_op)';
            end
        end
    end
    
    name = ['setup_' int2str(Factor) '_' benchmark{case_i}]; fid1=fopen(name,'w');
    fclose(fid1);
    
    fid2 = fopen(name, 'a');
    for i_set = 1:length(line1)
        fprintf(fid2, '%d ', line1(i_set));
    end
    fprintf(fid2, '\n');
    
    for i_set = 1:size(setup, 1)
        for j_set = 1:size(setup, 2)
            fprintf(fid2,'%d ', setup(i_set, j_set));
        end
        fprintf(fid2, '\n');
    end
    fclose(fid2);
end

