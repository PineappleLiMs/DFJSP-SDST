function [ final_best_value, final_best_solution,nfe,cput,totalt,trend] = nwk_ss( maxb,data,max_nfe,maxd,t0SA,method )
%% the main function of scatter search algorithm
% nwk_ss: The function is mainly coding based on the algorithm in the paper
% "some aspects of scatter search in the folw shop problem"; The initial
% scheme and improvement method have some difference with the basic framework.
%input_args :maxb          , the maximum number of the primal reference set;
%            data          , the machine property cell and the job property vector
% data.m = m; data.c = c; data.t = t;  S = Specimen(1,:); Type = Specimen(2,:);
% data.tran = tran; data.DD = DD; data.Specimen = Specimen;
%            max_nfe       , the maximum iteration in the process of search
%            maxd          , the terminal condition on the maximum distance

%output_args:final_best_value    , the best cost function valueof proposed solutions
%            final_best_solution , the best solutions in the context of tested problem
%            nfe                 , the total number of evaluation
%            cput and totalt     , the value on the elapsed time
%            trend               ,the converage line
%
t0=cputime;
tic;
%% initial stage//diversification_generator
dimension = size(data.process, 1);
popsize = max(20,(dimension*0.05));
refset = zeros(maxb, dimension*size(data.process,3));
[ini_fitness,ini_solution] = RAER(data, popsize);

%% initial stage//built the initial reference set
[a,b] = sort(ini_fitness);
ref_fitness = a(1:maxb);
for i = 1:maxb
    refset(i,:) = ini_solution{b(i)};
end
for i = 1:maxb
    dis_recorder(i) = r_distance(refset(1,:),refset(i,:));
end
[dis_s2t,distant_index] = max(dis_recorder);

%% initialization of output results
trend(1) = ref_fitness(1);
% t0=cputime;
% tic;
nfe = popsize;

cput = cputime - t0;
%% iterated section
while cput < max_nfe
    
    %% select the subset of refset(referense set)
    starting_point=refset(1,:);
    terminal_point=refset(distant_index,:);
    slct_subset{1}.solution(1,:) = starting_point;
    slct_subset{1}.fitness(1) = ref_fitness(1);
    slct_subset{1}.solution(2,:) = terminal_point;
    slct_subset{1}.fitness(2) = ref_fitness(distant_index);
    
    %% combination based on the path relinking scheme
    [new_solution,new_cost,com_trend] = combination_method(data,trend(end),slct_subset,1);
%     new_cost
    trend = [trend,com_trend];
    nfe = nfe + 1;
    popsize = size(new_solution,1);
    new_sol_index = 1;
    
    cput = cputime - t0;
    if cput > max_nfe
        break
    end
    
    %% improve the new trail solution in iterated local search
    [new_cost(new_sol_index),new_solution(new_sol_index,:),ls_trend,ls_nfe] = local_search_sa(t0SA,new_cost(new_sol_index),new_solution(new_sol_index,:),data,trend(end),method);
%     new_cost
    trend = [trend,ls_trend];
    
    nfe = ls_nfe + nfe;
    
    %% update the refset(referense set)
    refset(distant_index,:) = [];
    ref_fitness(distant_index) = [];
    dis_recorder(distant_index) = [];
    
    if new_cost(new_sol_index) < ref_fitness(1)
        refset(2:maxb,:) = refset;
        ref_fitness(2:maxb) = ref_fitness;
        refset(1,:) = new_solution(new_sol_index,:);
        ref_fitness(1) = new_cost(new_sol_index);
        for i = 1:maxb
            dis_recorder(i) = r_distance(refset(1,:),refset(i,:));
        end
    else
        refset(maxb,:) = new_solution(new_sol_index,:);
        ref_fitness(maxb) = new_cost(new_sol_index);
        dis_recorder(maxb) = r_distance(refset(1,:),new_solution(new_sol_index,:));
    end
    t0SA = 0.9*t0SA;
    
    [dis_s2t,distant_index] = max(dis_recorder);
    %     if dis_s2t<maxd
    %         break
    %     end
%     if length(trend)>5000 && (trend(end-5000)==trend(end))
%         break
%     end
%     if length(trend)>20 && (trend(end-20)==trend(end))
%         break
%     end
    cput = cputime - t0;
end

final_best_value = ref_fitness(1);
final_best_solution = refset(1,:);
cput = cputime-t0;
totalt = toc;
end
