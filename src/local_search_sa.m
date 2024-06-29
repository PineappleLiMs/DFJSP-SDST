function [endvalue,endsolution,ls_trend,nfesa]=local_search_sa(t0SA,startvalue,startsolution,data,bestsf,method)
% local_search normal local search operator with simulated annealing
%  input_args:  t0SA        , the tempurature of simulated annealing
%              startvalue   , the cost function of start point
%              startsolution, the start point in search process of local_search_sa
%              data         , the process_time matrix and the number of job and machine of one given problem
% output_args: endvalue     , the terminal solution  in search process of local_search_sa
%              endsolution  , the cost function of terminal point
%              nfesa        , the number of evualation

gbestval = startvalue;
temp_solution = startsolution;
nfesa = 0;
iteration = size(startsolution, 2);
while nfesa < min( iteration*(iteration-1), 2500)
    switch method
        case 1
            solution = inverse(temp_solution);
        case 2
            solution = insert(temp_solution);
        case 3
            solution = swap(temp_solution);
        otherwise
            error('unsupported local search method')
    end
    temp_cost = dfjsp_setup(solution,data);
    nfesa = nfesa + 1;
    
    % updata the gbest
    if temp_cost > gbestval
        if min(1,exp((gbestval-temp_cost)/t0SA)) > rand
            temp_solution = solution;
        end
    else
        gbestval = temp_cost;
        temp_solution = solution;
        
    end
    
    bestsf = min(gbestval,bestsf);
    ls_trend(nfesa) = bestsf;
end
endsolution = temp_solution;
endvalue = gbestval;
end