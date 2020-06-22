function scores = compute_fitness_population(x,store,daySlot,countEmployee,genderEmployee,experienceEmployee,salaryEmployee,dayWeek)
%% COMPUTE_FITNESS_POPULATION
%
% Main fitness function. Computes the whole population fitness
%
% Copyright (C) 2020 
%
% This program is free software; you can redistribute it and/or
% modify it under the terms of the GNU General Public License
% as published by the Free Software Foundation; either version 2
% of the License, or (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
%%
scores = zeros(size(x,1),1);
for j = 1:size(x,1)     
    [f assignedStores totalSalary] = compute_fitness(x(j,:),store,daySlot,countEmployee,genderEmployee,experienceEmployee,salaryEmployee,dayWeek);
    scores(j) = f;
end
fprintf('.');