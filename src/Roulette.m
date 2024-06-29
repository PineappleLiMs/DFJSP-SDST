%% Roulette strategy 
%
% File name: Roulette.m
%
% Description:
% pick out an individual from the population following Roulette strategy
% return the Roulette results of num times
%
% Input
%  -- P
%  -- num
% Output
%  -- Select
%
% MATLAB 8.5.0.197613 (R2015a) 64-bit
% Cristina Wang| School of Business and Management | Beihang University
% No. 37 Xueyuan Road, Haidian District, Beijing 100191, China
% Email: kywang@buaa.edu.cn or cristinawang95@gmail.com
% Contact me if any errors, comments or enquiries arise
%
% $Revision: 1.0.0 $  $Date:: 2017/02/20 - 201-/--/-- --:-- $
%
function Select = Roulette(P,num)

m = length(P);
Select = zeros(1,num);
rand('twister',mod(floor(now*8640000),2^31-1));
r = rand(1,num);
for i=1:num
    sumP = 0;
    j = ceil(m*rand); % get random whole numbers in [1,m]
    while sumP < r(i)
        sumP = sumP + P(mod(j-1,m)+1);
        j = j+1;
    end
    %Select(i) = mod(j-1,m)+1-1;
    Select(i) = mod(j-2,m)+1;
end

