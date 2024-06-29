function [J] = swap(J)
%% swap operator
% randomly swap two items in the row of operation
% output: the modified permutation
u = datasample(1:size(J, 2), 1);
v = datasample(1:size(J, 2), 1);
while J(v) == J(u)
    v = datasample(1:size(J, 2), 1);
end
tempJ=J(:, u);
J(:, u)=J(:, v);
J(:, v)=tempJ;
end