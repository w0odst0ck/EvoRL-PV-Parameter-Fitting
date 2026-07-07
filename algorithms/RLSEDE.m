function [position, value] = RLSEDE(N, range, dim, Max_iter, NEF, fobj)
    disp('RLSEDE is now estimating the global optimum for your problem....')    
    popsize = N;
    Maxfes = NEF;
    position = zeros(1, dim);
    value = zeros(1, 1);

    tic
    rand('seed', sum(100 * clock));
    lu = range;
    uSet = zeros(popsize, dim);

    % Initialize the main population
    p = repmat(lu(1, :), popsize, 1) + rand(popsize, dim) .* (repmat(lu(2, :) - lu(1, :), popsize, 1));

    % Evaluate the objective function values
    FES = 0;
    fit = zeros(popsize, 1);

    for i = 1:popsize
        fit(i) = fobj(p(i, :));
        FES = FES + 1;
    end

    record(1) = min(fit);
    G = 1;

    % Initialization for Reinforcement Learning
    State_pop = 2 * ones(popsize, 1); 
    Action_pop = zeros(size(State_pop)); 
    trial_State = State_pop;
    alp = 0.1; % Q-learing rate
    gamma = 0.9; 
    Q_Agent = zeros(2.*popsize, 3);
    R = zeros(popsize, 1);

    while FES < Maxfes
        G = G + 1;
        pTemp = p;
        fitTemp = fit;

        for i = 1:popsize
            % The three control parameter settings
            F = [1.0 1.0 0.8];
            CR = [0.1 0.9 0.2];

            % Uniformly and randomly select one of the control
            % parameter settings for each trial vector generation strategy
            paraIndex = floor(rand * length(F)) + 1;
%SEDE:
%             if rand > FES / Maxfes
%                 % Generate the trial vectors by the group1
%                 u = group1(p, lu, i, F, CR, popsize, dim, paraIndex);
%             else
%                 % Generate the trial vectors by the group1
%                 [~, best_index] = min(fit);
%                 u = group2(p, lu, i, F, CR, popsize, dim, paraIndex, best_index);
%             end
% 
%             uSet(i, :) = u;
            
            %% Reinforcement Learning
            Agent_current = p(i,:);
            Qtemp = Q_Agent(2*i-1:2*i,:);
            AgState = State_pop(i); 
            Qvalue1 = Qtemp(AgState,:); 
            temp = exp(Qvalue1);
            ratio = cumsum(temp)/sum(temp); 
            jtemp = find(rand(1) < ratio);
            adjustment = jtemp(1);         % action: F 
            Action_pop(i) = adjustment;  
            
            switch adjustment
                case 1
                    % Generate the trial vectors by the group1
                    u = group1(p, lu, i, F, CR, popsize, dim, paraIndex);
                case 2
                    % Generate the trial vectors by the group2
                    [~, best_index] = min(fit);
                    u = group2(p, lu, i, F, CR, popsize, dim, paraIndex, best_index);
                case 3
                    % Generate the trial vectors by the group1
                    u = group1(p, lu, i, F, CR, popsize, dim, paraIndex); 
            end
            
            uSet(i, :) = u;

            % Evaluate the trial vector
            fitSet(i) = fobj(u);
            FES = FES + 1;
            
            % Determine the reward
            if fit(i) >= fitSet(i)
                R(i) = 1;
                trial_State(i,:) = 1; 
            else
                R(i) = 0;
                trial_State(i,:) = 2;  
            end
        end

        % Update Q-values
        for kp = 1:popsize
            Qtemp = Q_Agent(2*kp-1:2*kp,:);
            AgState = State_pop(kp); 
            Action = Action_pop(kp);
            NextState = trial_State(kp); 
            temp = max(Qtemp(NextState,:));
            Qtemp(AgState,Action) = (1-alp)*Qtemp(AgState, Action) + alp*(R(kp) + gamma*temp); 
            Q_Agent(2*kp-1:2*kp,:) = Qtemp;
        end
        
        % Update state
        State_pop = trial_State;

        % Update population and fitness values
        for i = 1:popsize
            if fit(i) >= fitSet(i)
                pTemp(i, :) = uSet(i, :);
                fitTemp(i) = fitSet(i);
            end
        end



        p = pTemp;
        fit = fitTemp;
        record(G) = min(fit);
    end

    [best_score, best_index] = min(fit);
    position = p(best_index, :);
    value = best_score;
end
%