function [J] = inverse(J)
%% inversep operator
% randomly inverse items between two items in the row of operation

u = datasample(1:size(J, 2), 1);
v = datasample(1:size(J, 2), 1);
while v == u
    v = datasample(1:size(J, 2), 1);
end
if u<v
    tempJ=J(:, u:v);
    J(:, u:v)=tempJ(:, end:-1:1);
else
    tempJ=J(:, v:u);
    J(:, v:u)=tempJ(:, end:-1:1);
end
end