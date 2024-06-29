function [ final_best_value, final_best_solution,nfe,cput,trend,Pro_record] = nwk_HH_RPD_SA( data,max_nfe,MaxLLH,t0SA )
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
selectPhase = 0;
%% iterated section
while cput < max_nfe
    %% improve the new trail solution in iterated local search
    bestsf = trend(end);
    Pro_record_ls = [];
    method_No = mod(selectPhase, MaxLLH) + 1;

    nfels = 0;
    ls_trend = [];
    iteration = max(data.process(3,:));
    while nfels < min( iteration*(iteration-1), 2500)
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
        
        % Move Acceptance - Simulated Annealing
        % updata the gbest
        if temp_cost > gbestval
            if min(1,exp((gbestval-temp_cost)/t0SA)) > rand
                solution = temp_solution;
            end
        else
            gbestval = temp_cost;
            solution = temp_solution; 
        end
        bestsf = min(gbestval,bestsf);
        ls_trend(nfels) = bestsf;
        
        if (length(ls_trend) > 500 && ls_trend(end) == ls_trend(end-500))
            break
        end
    end
    
    record = [nfels; method_No];
    Pro_record_ls = [Pro_record_ls, record];
    ls_nfe = nfels;
    
    % update the temperature
    t0SA = 0.9*t0SA;
    
    trend = [trend,ls_trend];
    Pro_record_ls(1,:) = Pro_record_ls(1,:) + nfe;
    Pro_record = [Pro_record, Pro_record_ls];
    nfe = ls_nfe + nfe;
    cput = cputime - t0;
    
    selectPhase = selectPhase + 1;
end
final_best_value = gbestval;
final_best_solution = gbestsolution;
cput = cputime-t0;
end
