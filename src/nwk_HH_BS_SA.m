function [ final_best_value, final_best_solution,nfe,cput,trend,Pro_record] = nwk_HH_BS_SA( data,max_nfe,MaxLLH,t0SA )
%% the main function of HyperHeuristics which start from random initialization
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
%% initial stage
dimension = size(data.process, 1);

popsize = 6;
[ini_fitness,ini_solution] = RAER(data, popsize);
[gbestval,b] = min(ini_fitness);
gbestsolution = ini_solution{b};
solution = gbestsolution;
trend = gbestval;

nfe = 1;
Pro_record = [];
cput = cputime - t0;

%% iterated section
probability = ones(MaxLLH, 1)*0.001;
NCall = zeros(MaxLLH, 1);
NImprove = zeros(MaxLLH, 1);
while cput < max_nfe
    %% improve the new trail solution in iterated local search
    bestsf = trend(end);
    Pro_record_ls = [];
    method_No = Roulette( probability, 1 );

    nfels = 0;
%     iteration = max(data.Specimen(3,:));
    while nfels < 1 % min( iteration*(iteration-1), 2500)
        switch method_No
            case 1
                temp_solution = inverse(solution);
            case 2
                temp_solution = insert(solution);
            case 3
                temp_solution = swap(solution);
        end
        temp_cost = dfjsp_setup(temp_solution,data);
        nfels = nfels + 1;
        NCall(method_No) = NCall(method_No) + 1;
        
        % Move Acceptance - Simulated Annealing
        % updata the gbest
        if temp_cost > gbestval
            if min(1,exp((gbestval-temp_cost)/t0SA)) > rand
                solution = temp_solution;
            end
        else
            gbestval = temp_cost;
            solution = temp_solution; 
            NImprove(method_No) = NImprove(method_No) + 1;
        end
        bestsf = min(gbestval,bestsf);
        ls_trend(nfels) = bestsf;
    end
    
    record = [nfels; method_No; probability];
    Pro_record_ls = [Pro_record_ls, record];
    ls_nfe = nfels;
    
    % update the temperature
    t0SA = 0.9*t0SA;
    
    trend = [trend,ls_trend];
    Pro_record_ls(1,:) = Pro_record_ls(1,:) + nfe;
    Pro_record = [Pro_record, Pro_record_ls];
    nfe = ls_nfe + nfe;
    cput = cputime - t0;
    
    probability(method_No) = probability(method_No) + NImprove(method_No)/NCall(method_No);
end
final_best_value = gbestval;
final_best_solution = gbestsolution;
cput = cputime-t0;
end
