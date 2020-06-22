function [assignedStores assignedEmployee assignedMixedEmployee daysWorkedEmployee] = assign_employee(index,allele,assignedEmployee,assignedMixedEmployee,assignedStores,genderEmployee,daysWorkedEmployee)
%% ASSIGN_EMPLOYEE
%
% Function responsible for mapping genotype to phenotype
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
% Cashiers -> row
% Maintance -> column

nCashiers = size(assignedEmployee,1);
nMaintance = size(assignedEmployee,2);
nMixed = length(assignedMixedEmployee);
nTimeslots = size(assignedStores,1);

% Locate chromosome index related to the assigned store and timeslot
rAssignedStores = rem(index,nTimeslots);
if(rAssignedStores == 0)
    rAssignedStores = nTimeslots;
end
cAssignedStores = ceil(index/nTimeslots);

conflictMatrix = zeros(nCashiers,nMaintance);
%% Hard constraints
% The objective of this section is to build the conflict matrix and based
% on this then allocate the employee in the available slots
%
% 1) Employee has to work 6 days or less
temp = [];
if((rem(rAssignedStores,4) == 0))
    for(i = rAssignedStores-3:rAssignedStores-1)
        temp = [temp;cell2mat(assignedStores(i,cAssignedStores))];
    end
    daysWorkedEmployee(unique(temp(:,1))) = daysWorkedEmployee(unique(temp(:,1))) + 1; %Cashiers
    daysWorkedEmployee(unique(temp(:,2))+nCashiers) = daysWorkedEmployee(unique(temp(:,2))+nCashiers) + 1; %Maintance
end        
conflictMatrix(daysWorkedEmployee(1:nCashiers) >= 6,:) = 1;
conflictMatrix(:,daysWorkedEmployee(nCashiers+1:nCashiers+nMaintance) >= 6) = 1;

% 2) Employee cannot work in different store at the same time slot
%    Note: avoid that an employee can reallocate to different store in the
%    same day although it would be possible because different timeslot
if((rAssignedStores >= 1) && (cAssignedStores > 1))
    for i = 1:7
        if((rAssignedStores >= ((i-1)*4)+1) && (rAssignedStores <= (i*4)))
            day = i;
            break;
        end
    end
    temp = [];
    for j = 1:cAssignedStores-1
        for i = ((day-1)*4+1):(day*4)-1
            temp = [temp; cell2mat(assignedStores(i,j))];            
        end
    end
    cashiersWorking = unique(temp(:,1));
    maintanceWorking = unique(temp(:,2));        
    conflictMatrix(cashiersWorking,:) = 1;
    conflictMatrix(:,maintanceWorking) = 1;
end

% 3) Female employee cannot work night shifts
if(rem(index,3) == 0)
    femCashier = genderEmployee(1:nCashiers);
    femMaintance = genderEmployee(nCashiers+1:nCashiers+nMaintance);
    conflictMatrix(:,femMaintance == 1) = 1;
    conflictMatrix(femCashier == 1,:) = 1;
end
%% Employee allocation
[cAssignedEmployee rAssignedEmployee] = locate_employee(conflictMatrix,allele);

assignedEmployee(rAssignedEmployee,cAssignedEmployee) = ...
assignedEmployee(rAssignedEmployee,cAssignedEmployee) + 1;

assignedStores{rAssignedStores,cAssignedStores} = [rAssignedEmployee,cAssignedEmployee];

%% Case for hybrid shift
if(rem(index,4) == 0)
    sumMixed = assignedMixedEmployee < 6;
    nMixedAval = sum(sumMixed);
    employeeIndex = ceil(allele * length(nMixedAval));
    if(employeeIndex == 0)
        employeeIndex = 1;
    end
    counter = 0;
    iEmployee = 1;
    for(i = 1:nMixed)
        if(sumMixed(i) == 1)
            counter = counter + 1;
        end
        if(counter == employeeIndex)
            iEmployee = i;
        end
    end
    assignedMixedEmployee(iEmployee) = assignedMixedEmployee(iEmployee) + 1;
    assignedStores{rAssignedStores,cAssignedStores} = iEmployee;
end
