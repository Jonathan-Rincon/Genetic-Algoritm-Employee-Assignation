function [f assignedStores totalSalary] = compute_fitness(x,store,daySlot,countEmployee,genderEmployee,experienceEmployee,salaryEmployee,dayWeek)
%% COMPUTE_FITNESS
%
% Individual fitness function. Computes a single individual fitness
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
timeSlot = zeros(length(daySlot)*length(dayWeek),1);

assignedStores = cell(length(timeSlot),length(store));
assignedEmployee = zeros(countEmployee(1),countEmployee(2));
assignedMixedEmployee = zeros(countEmployee(3),1);
daysWorkedEmployee = zeros(countEmployee(1)+countEmployee(2)+countEmployee(3),1);
nCashiers = countEmployee(1);
nMaintance = countEmployee(2);

for i = 1:length(x)
    [assignedStores assignedEmployee assignedMixedEmployee daysWorkedEmployee] = assign_employee(i,x(i),assignedEmployee,assignedMixedEmployee,assignedStores,genderEmployee,daysWorkedEmployee);
end

%% Soft constraints
% 1) An employee shouldn't work two continuous shifts
penalty1Cashier = zeros(countEmployee(1),1);
penalty1Maintance = zeros(countEmployee(2),1);
for i = 1:size(assignedStores,2)
    for j = 1:size(assignedStores,1)-2
        if((assignedStores{j,i}(1) == assignedStores{j+1,i}(1)) && (rem(j,4) ~= 0) && (rem(j,4) ~= 3))
            penalty1Cashier(assignedStores{j,i}(1)) = penalty1Cashier(assignedStores{j,i}(1)) + 1;
        end
        if((rem(j,4) ~= 0) && (rem(j,4) ~= 3))
            if(assignedStores{j,i}(2) == assignedStores{j+1,i}(2))
                penalty1Maintance(assignedStores{j,i}(2)) = penalty1Maintance(assignedStores{j,i}(2)) + 1;
            end
        end
    end
end
penalty1Employee = sum(penalty1Cashier) + sum(penalty1Maintance);
% 2) Workers with more experience are rewarded according for the maintance
%    position
penalty2Employee = 0;
for i = 1:size(assignedStores,2)
    for j = 1:size(assignedStores,1)-1
        if(rem(j,4) ~= 0)
            penalty2Employee = penalty2Employee + experienceEmployee(nCashiers+assignedStores{j,i}(2));
        end
    end
end
% 3) Balance the employee experience among the shifts for a given day
penalty3Employee = 0;
for i = 1:size(assignedStores,2)
    for j = 1:size(assignedStores,1)-1
        if(rem(j,4) ~= 0)
            penalty3Employee = penalty3Employee + experienceEmployee(assignedStores{j,i}(1)) + ...
                experienceEmployee(assignedStores{j,i}(2));
        end
    end
end

% 4) Favor employees working at the same store
temp = zeros(length(experienceEmployee),length(store));
% Calculate number of shifts worked per employee per store
for i = 1:size(assignedStores,2)
    for j = 1:size(assignedStores,1)-1
        if(rem(j,4) ~= 0)
            temp(assignedStores{j,i}(1),i) = temp(assignedStores{j,i}(1),i) + 1;
            temp(assignedStores{j,i}(2)+countEmployee(1),i) = temp(assignedStores{j,i}(2)+countEmployee(1),i) + 1;
        else
            temp(assignedStores{j,i}(1)+countEmployee(2)+countEmployee(1),i) = temp(assignedStores{j,i}(1)+countEmployee(2)+countEmployee(1),i) + 1;
        end
    end
end
% sum the non-working stores
A = sum(temp'==0)';
penalty4Employee = sum(A<6);

% 5) Salary
shiftsMaintance = sum(assignedEmployee,1);
shiftsCashiers = sum(assignedEmployee,2)';
shiftsMixed = assignedMixedEmployee';
salaryCashiers = salaryEmployee(1:countEmployee(1));
salaryMaintance = salaryEmployee(countEmployee(1)+1:countEmployee(1)+countEmployee(2));
salaryMixed = salaryEmployee(countEmployee(1)+countEmployee(2)+1:countEmployee(1)+...
    countEmployee(2)+countEmployee(3));
salaryStores = zeros(1,length(store));
for(i = 1:length(timeSlot))
   if(rem(i,4)==0)
       shiftSalary = salaryMixed(cell2mat(assignedStores(i,:)));
   else
       temp = vertcat(assignedStores{i,:});
       shiftSalaryCashiers = salaryCashiers(temp(:,1));
       shiftSalaryMaintance = salaryMaintance(temp(:,2));
       shiftSalary = shiftSalaryCashiers + shiftSalaryMaintance;       
   end
   salaryStores = salaryStores + shiftSalary;
end
totalSalary = sum(salaryStores);

%% Final fitness function
f1 = penalty1Employee;
f2 = penalty2Employee;
f3 = penalty3Employee;
f4 = penalty4Employee;
f5 = totalSalary/100;
f = f5 + f1 - f2 - f3 - f4;


