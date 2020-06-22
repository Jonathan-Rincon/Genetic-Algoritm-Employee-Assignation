function [state,options,optchanged] = outfun(options,state,flag)
global history;

optchanged = false;
switch flag
    case 'init'
        disp('Starting the algorithm');
    case {'iter','interrupt'}
        disp('Iterating ...')
        if~isempty(history)
            history.meanFitness = [history.meanFitness; mean(state.Score)];
            history.bestFitness = [history.bestFitness; state.Best(end)];
        else
            history.meanFitness = mean(state.Score);
            history.bestFitness = state.Best(end);
        end
    case 'done'
        disp('Performing final task');
end