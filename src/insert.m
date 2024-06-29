function [J] = insert(J)
%% insert operator
% randomly Insert operation in uth position into the vth position in the row of operation, i.e.,the 1st row of J
u = datasample(1:size(J, 2), 1);
v = datasample(1:size(J, 2), 1);
while J(v) == J(u)
    v = datasample(1:size(J, 2), 1);
end
if u>v
    temp = v;
    v = u;
    u = temp;
end
    tempJ=J(:, v);
    J(:, (u+1):v)=J(:, u:(v-1));
    J(:, u)=tempJ;
end
