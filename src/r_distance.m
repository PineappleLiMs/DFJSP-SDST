function [measure] = r_distance(permutation1,permutation2)
% calculate the r-distance between permutation1 and permutation2 in
% context of flowshop problem
% input : two sequence permuatation1 and permuatation2
% output: the measure that indicate the distance of input

if iscell(permutation1)
    permutation1 = permutation1{1};
end
if iscell(permutation2)
    permutation2 = permutation2{1};
end

dimension = size(permutation1,2);
measure = 0;
[~,inverse_permuatation1] = sort(permutation1);
[~,inverse_permuatation2] = sort(permutation2);


for i = 1:dimension
    for j = 1:dimension
        if i ~= j
            if inverse_permuatation1(i) < inverse_permuatation1(j)&&...
                    inverse_permuatation2(i) < inverse_permuatation2(j)
               measure = measure + 1;
            end
        end
    end
end

measure = ((dimension*(dimension-1))-2*measure)/(dimension*(dimension-1));


% test :
% permuatation1=[3,2,1,4];
% permuatation2=[3,2,4,1];
% [measure]=r_distance(permuatation1,permuatation2);
% measure=1/6;
% [measure]=r_distance(permuatation1,permuatation1);
% measure=0;


    