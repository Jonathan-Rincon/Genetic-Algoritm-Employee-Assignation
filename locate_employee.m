function [cAssignedEmployee rAssignedEmployee] = locate_employee(conflict,allele)
%% LOCATE_EMPLOYEE
%
% Based on a conflict matrix, this function selects the candidate employee
% to be assigned.
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
counter = 0;
nEmployeeAval = sum(sum(conflict == 0));
employeeIndex = ceil(nEmployeeAval*allele);
if(allele == 0)
    employeeIndex = 1;
end
cAssignedEmployee = [];
rAssignedEmployee = [];
for j = 1:size(conflict,2)
    for i = 1:size(conflict,1)
        if(conflict(i,j) == 0)
            counter = counter + 1;
        end
        if(counter == employeeIndex)
            cAssignedEmployee = j;
            rAssignedEmployee = i;
            return;
        end
    end
end

employeeIndex;

