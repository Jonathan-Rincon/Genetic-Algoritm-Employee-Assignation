clear all;

%% Employee assignation algorithm for a AMPM store chain
%
%       The algorithm uses a Genetic Algorithm as the minimization solver.
%       It currently works as a proof of concept. The main objective 
%       function is the minimization of employee costs. The code is not
%       optimized so the program execution is slow at the current state.
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


%% Database
%raw_data = readtable('Data.xlsx');%Load data base.
raw_data = readtable('Data.xlsx','Sheet','ALL');%Load data base from a specific sheet
value_data = readtable('Data.xlsx','Sheet','RESUME'); 
value_dayslot = readtable('Data.xlsx','Sheet','DAY_SLOT');
value_store = readtable('Data.xlsx','Sheet','STORES');
value_weekdays = readtable('Data.xlsx','Sheet','WEEK_DAYS');
%% Parameters
store = value_store{:,1}';
daySlot = value_dayslot{:,1}';% DaySlot Ex: Morning, Afternoon..
positionEmployee = value_data{:,1}'; % Column positions from resume - Cashier - Maintance - Mixed
countEmployee = value_data{:,2}';% Column count employee - each number corresponds to the above positions %countEmployee = xlsread('Data.xlsx','RESUME','B1:B4')'; %read specif for no containt NaN %genderEmployee =  readtable('Data.xlsx','Range','D1:D71');
genderEmployee = raw_data{:,5}';% Column "CODE_GENDER 1: Female 0: Male
experienceEmployee = raw_data{:,10}'; 
salaryEmployee = raw_data{:,12}'; %Column salary per shift = salary hour * 8 hours
dayWeek = value_weekdays{:,1}';
timeSlot = zeros(length(daySlot)*length(dayWeek),1);
%% GA
fitnessFunction = @(x) compute_fitness_population(x,store,daySlot,countEmployee,genderEmployee,experienceEmployee,salaryEmployee,dayWeek);
options = optimoptions(@ga,'MaxGenerations',100,'PopulationSize',200, ...
                            'PlotFcn', @gaplotbestf, ... 
                            'MutationFcn', {@mutationadaptfeasible, 0.1}, ...
                        'MaxStallGenerations',50,'UseVectorized',true, ...
                        'OutputFcn',@outfun);
lgenotype = length(timeSlot)*length(store);
global history;

for iRun = 1:2
    history = [];
    [x,fval,reason,output] = ga(fitnessFunction,lgenotype,[],[],[],[],zeros(lgenotype,1),ones(lgenotype,1),[],options);

    [f, assignedStores totalSalary] = compute_fitness(x,store,daySlot,countEmployee,genderEmployee,experienceEmployee,salaryEmployee,dayWeek);
    outputData{iRun}.assignedStores = assignedStores;
    outputData{iRun}.totalSalary = totalSalary;
    outputData{iRun}.meanFitness = history.meanFitness;
    outputData{iRun}.bestFitness = history.bestFitness;
end
save('outputData.mat','outputData');
%% Small summary report generation
daySlots = vertcat(daySlot',daySlot',daySlot',daySlot',daySlot',daySlot',daySlot');
dayWeeks = cell(28,1);
for i = 1:7
   dayWeeks{((i-1)*4)+1,1} = dayWeek{i};
   dayWeeks{((i-1)*4)+2,1} = dayWeek{i};
   dayWeeks{((i-1)*4)+3,1} = dayWeek{i};
   dayWeeks{((i-1)*4)+4,1} = dayWeek{i};
end
for j = 1:7
    for i = 1:28
        if(rem(i,4) ~= 0)
            Store{i,j} = ['Cashier: Employee ' num2str(assignedStores{i,j}(1)) ...
                ' - Maintance: Employee ' num2str(assignedStores{i,j}(2))];
        else
            Store{i,j} = ['Asist. Employee ' num2str(assignedStores{i,j}(1))];
        end
    end
end
typeEmployee = cell(countEmployee(1) + countEmployee(2) + countEmployee(3),1);
typeEmployee(1:countEmployee(1)) = {positionEmployee{1}};
typeEmployee(countEmployee(1)+1:countEmployee(1)+countEmployee(2)) = {positionEmployee{2}};
typeEmployee(countEmployee(1)+countEmployee(2)+1:countEmployee(1)+countEmployee(2)+countEmployee(3)) = {positionEmployee{3}};
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
%Report = table(dayWeeks,daySlots,Store(:,1),Store(:,2),Store(:,3),Store(:,4),Store(:,5),Store(:,6),Store(:,7));
Report = table(dayWeeks,daySlots,Store); %Le quit� los (:1..7) para que en el archivo mostrar� Store_1, Store_2..etc 
Salary = table(typeEmployee,salaryEmployee');
ExpensesStores = table(store',salaryStores');
filename = 'Report.xlsx';
writetable(Salary,filename,'Sheet','Salary','Range','A1');
writetable(Report,filename,'Sheet','Summary','Range','A1');
writetable(ExpensesStores,filename,'Sheet','Costs','Range','A1');