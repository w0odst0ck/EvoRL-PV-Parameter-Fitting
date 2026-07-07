function [position, value] = SEDE(N, range, dim, Max_iter, NEF, fobj)
    disp('SEDE is now estimating the global optimum for your problem....')    
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

            if rand > FES / Maxfes
                % Generate the trial vectors by the group1
                u = group1(p, lu, i, F, CR, popsize, dim, paraIndex);
            else
                % Generate the trial vectors by the group1
                [~, best_index] = min(fit);
                u = group2(p, lu, i, F, CR, popsize, dim, paraIndex, best_index);
            end

            uSet(i, :) = u;
        end

        % Evaluate the trial vectors
        for i = 1:popsize
            fitSet(i) = fobj(uSet(i, :));
            FES = FES + 1;
        end

        for i = 1:popsize
            % Choose the better one from the trial vector and the target vector
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
    value= best_score;
end
