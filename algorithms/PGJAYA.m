function [position, value] = PGJAYA(N, range, dim, Max_iter, NEF, fobj)
    disp('PGJAYA is now estimating the global optimum for your problem....')    

    position = zeros(1, dim);
    value = zeros(1, 1);

    tic
    rand('seed', sum(100 * clock));
    Xmin = lu(1, :);
    Xmax = lu(2, :);
    D = dim;
    FE_best=[];
    % Initialize the main population
    X = repmat(lu(1, :), N, 1) + rand(N, dim) .* (repmat(lu(2, :) - lu(1, :), N, 1));

    % Evaluate the objective function values
    FES = 0;
    fit = zeros(N, 1);

    for i = 1:N
        fit(i) = fobj(X(i, :));
        FES = FES + 1;
    end

    G = 1;

    M_X=rand;

    while FES < NEF

        G = G + 1;
        [index1,index2]=sort(fit);
        Seq = 1:N;
        R = N-Seq;
        p = (R/N).^2;
        pp(index2)=p;
        Best = X(index2(1),:);
        Worst= X(index2(end),:);
        if fit(index2(end),:)==0
            ww=1;
        else
            ww=abs(fit(index2(1),:)/(fit(index2(end),:)))^2;
        end
        
        for i=1:N       
                
            if rand>pp(i)    
                for j=1:D
                    Xi(j) = X(i,j) + rand*(Best(j)-abs(X(i,j)))-ww*rand*(Worst(j) -abs(X(i,j)));
                end
            else             
                nouse1(1)= randi(N);
                while nouse1(1)==i || rand>pp(nouse1(1)) 
                    nouse1(1)= randi(N);
                end
                nouse1(2)= randi(N);
                while nouse1(2)==i || nouse1(2)==nouse1(1)
                    nouse1(2)= randi(N);
                end
                Xi = X(i,:) + rand(1,D).*(X(nouse1(1),:) -X(nouse1(2),:)); 
            end
                
            Xi = boundConstraint_absorb(Xi, Xmin, Xmax);
            fiti = fobj(X(i, :));
            FES = FES+1;
            if fiti<fit(i,:)
                fit(i,:) = fiti;
                X(i,:) = Xi;
            end
            FES=FES+1;
            FE_best(FES) =  min(fit);
        end


        [~,index_Best] = sort(fit);
        Best = X(index_Best(1),:);
        M_X=4*M_X*(1-M_X);                      %%%%Local searching
        for k=1:D
            if rand<1-FES/NEF
                newX(k)=Best(k)+rand*(2*M_X-1);
            else
                newX(k)=Best(k);              
            end
        end
        newX = boundConstraint_absorb(newX, Xmin, Xmax);
        new_val = fobj(newX);
        FES = FES + 1;
            
        if new_val<fit(index_Best(end),:)  
            fit(index_Best(end),:) = new_val;
            X(index_Best(end),:) = newX;
        end
    
    end

    [best_score, best_index] = min(fit);
    position = X(best_index, :);
    value= best_score;
end
