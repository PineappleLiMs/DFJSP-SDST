clc, clear
% set up parallel environment
delete(gcp('nocreate'))
parpool('local', 20)  % set number of cores

% set benchmark instances
benchmark_path = '../benchmark/DFJSP';
benchmark = {'la01.fjs'; 'la02.fjs'; 'la03.fjs'; 'la04.fjs'; ...
    'la05.fjs'; 'la06.fjs'; 'la07.fjs'; 'la08.fjs'; ...
    'la09.fjs'; 'la10.fjs'; 'la11.fjs'; 'la12.fjs'; ...
    'la13.fjs'; 'la14.fjs'; 'la15.fjs'; 'la16.fjs'; ...
    'la17.fjs'; 'la18.fjs'; 'la19.fjs'; 'la20.fjs'; ...
    'mt06.fjs'; 'mt10.fjs'; 'mt20.fjs'};

case_index_list = 1:length(benchmark);
cell_num_list = [2,3,4];
setup_factors = [25,50,100];

% algorithm settings
run_settings = struct('repeat_num', 20, 'max_time_parameter', 6);
% data-saving settings
save_path_base = '../result/main_run/';
trend_length = 50;

algorithms = {'QIG', 'SS', 'SA', 'HH-RPD-SA', 'HH-BS-SA', 'IG1', 'IG2', 'IG3'};
% QIG、SS、SA: 对应文中的同名算法
% HH-RPD-SA和HH-BS-SA: 对应文中的HH-RPD和HH-BS
% IG1、IG2、IG3: 对应文中的IG-1、IG-2、IG-3
for algorithm = algorithms
    algorithm_name = algorithm{1};
    save_path = [save_path_base, algorithm_name, '/raw_data/'];
    algorithm_run(algorithm_name, benchmark_path, benchmark, cell_num_list,...
        case_index_list, setup_factors, run_settings, save_path);
    dealed_data_path = [save_path_base, algorithm_name, '/'];
    deal_data(algorithm_name, benchmark, cell_num_list, case_index_list, ...
        setup_factors, save_path, dealed_data_path, trend_length);
end