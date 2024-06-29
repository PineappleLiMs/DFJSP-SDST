function [new_pop,new_pop_cost,com_trend] = combination_method(data,bestsf,slct_subset,type)
%% to produce the new solution based the path relinking
% see in Marti 2002 and Fred Glover 1994b
% input : slct_subset   , the combination subsets
%         type          , the type of combination method
%         data          , the process_time matrix and the number of job and machine
% output: new_pop       , the new population generated by path relinking
%         new_pop_cost  , the fitness of new population

popsize = size(slct_subset,2);
dimension = size(slct_subset{1}.solution(1,:),2);
new_pop = zeros(popsize,dimension);
new_pop_cost = slct_subset{1}.fitness;

for index = 1:popsize
    parent1 = slct_subset{index}.solution(1, :);
    parent2 = slct_subset{index}.solution(2, :);
    fitness_temp = 1./slct_subset{index}.fitness;
    weight = fitness_temp/sum(fitness_temp);
    current_score = zeros(dimension,2);
    history_score = zeros(dimension,2);
    [~,location_record1] = sort(parent1);
    [~,location_record2] = sort(parent2);
    parent_record1 = parent1;
    parent_record2 = parent2;
    
    if parent1(1) == parent2(1)
        new_pop(index,1) = parent1(1);
        parent1(1) = [];
        parent2(1) = [];
        suc_element1 = 1;
        suc_element2 = 1;
    else
        if weight(1) > weight(2)
            new_pop(index,1) = parent1(1);
            temp_2 = find(parent2 == parent1(1));
            parent1(1) = [];
            parent2(temp_2(1)) = [];
            current_score(1,:) = [1,0];
            history_score(1,:) = [1,0];
            suc_element1 = 1;
            suc_element2 = temp_2(1);
        else
            new_pop(index,1) = parent2(1);
            temp_1 = find(parent1==parent2(1));
            parent1(temp_1(1)) = [];
            parent2(1) = [];
            current_score(1,:) = [0,1];
            history_score(1,:) = [0,1];
            suc_element2 = 1;
            suc_element1 = temp_1(1);
        end
    end
    
    switch type
        case 1
            % Combination method 7 in Marti, 2002
            for inner_index = 2:dimension
                if parent1(1) == parent2(1)
                    new_pop(index,inner_index) = parent1(1);
                    parent1(1) = [];
                    parent2(1) = [];
                    current_score(inner_index,:) = [0,0];
                    history_score(inner_index,:) = history_score((inner_index-1),:)...
                        + current_score(inner_index,:);
                else
                    temp1_history_score = history_score((inner_index-1),:) + [1,0];
                    temp2_history_score = history_score((inner_index-1),:) + [0,1];
                    temp3_history_score = temp1_history_score/sum(temp1_history_score) - weight;
                    temp4_history_score = temp2_history_score/sum(temp2_history_score) - weight;
                    cri1 = abs(temp3_history_score(1)) + abs(temp3_history_score(2));
                    cri2 = abs(temp4_history_score(1)) + abs(temp4_history_score(2));
                    if cri1 < cri2
                        re_index = 1;
                    else
                        re_index = 2;
                    end
                    
                    if re_index==1
                        new_pop(index,inner_index)=parent1(1);
                        temp_2=find(parent2==parent1(1));
                        parent1(1)=[];
                        parent2(temp_2(1))=[];
                        current_score(inner_index,:)=[1,0];
                        history_score(inner_index,:)=history_score((inner_index-1),:)...
                            +current_score(inner_index,:);
                    else
                        new_pop(index,inner_index)=parent2(1);
                        temp_1=find(parent1==parent2(1));
                        parent1(temp_1(1))=[];
                        parent2(1)=[];
                        current_score(inner_index,:)=[0,1];
                        history_score(inner_index,:)=history_score((inner_index-1),:)...
                            +current_score(inner_index,:);
                    end
                end
            end
                   case 2
            % Combination method 8 in Marti, 2002
            for inner_index=2:dimension
                if parent1(1)==parent2(1)
                    new_pop(index,inner_index)=parent1(1);
                    parent1(1)=[];
                    parent2(1)=[];
                else
                    if location_record1(parent1(1))==location_record2(parent2(1))
                        if weight(1)>weight(2)
                            new_pop(index,inner_index)=parent1(1);
                            temp_2=find(parent2==parent1(1));
                            parent1(1)=[];
                            parent2(temp_2(1))=[];
                        else
                            new_pop(index,inner_index)=parent2(1);
                            temp_1=find(parent1==parent2(1));
                            parent1(temp_1(1))=[];
                            parent2(1)=[];
                        end
                    elseif location_record1(parent1(1))<location_record2(parent2(1))
                        new_pop(index,inner_index)=parent1(1);
                        temp_2=find(parent2==parent1(1));
                        parent1(1)=[];
                        parent2(temp_2(1))=[];
                    else
                        new_pop(index,inner_index)=parent2(1);
                        temp_1=find(parent1==parent2(1));
                        parent1(temp_1(1))=[];
                        parent2(1)=[];
                    end
                end
            end
            
        case 3
            for inner_index=2:dimension
                
                
                if suc_element1==dimension+2-inner_index
                    temp_index1=1;
                else
                    temp_index1=suc_element1;
                end
                
                if suc_element2==dimension+2-inner_index
                    temp_index2=1;
                else
                    temp_index2=suc_element2;
                end
                
                if parent1(temp_index1)==parent2(temp_index2)
                    new_pop(index,inner_index)=parent1(temp_index1);
                    parent1(temp_index1)=[];
                    parent2(temp_index2)=[];
                    suc_element1=temp_index1;
                    suc_element2=temp_index2;
                else
                    if rand<weight(1)
                        new_pop(index,inner_index)=parent1(temp_index1);
                        temp_2=find(parent2==parent1(temp_index1));
                        parent1(temp_index1)=[];
                        parent2(temp_2(1))=[];
                        suc_element1=temp_index1;
                        suc_element2=temp_2(1);
                    else
                        new_pop(index,inner_index)=parent2(temp_index2);
                        temp_1=find(parent1==parent2(temp_index2));
                        parent1(temp_1(1))=[];
                        parent2(temp_index2)=[];
                        suc_element2=temp_index2;
                        suc_element1=temp_1(1);
                    end
                end
            end
    end
    [new_pop_cost(index), ~] = dfjsp_setup(new_pop(index, :), data);
    bestsf = min(new_pop_cost(index), bestsf);
    com_trend = bestsf;
end
end