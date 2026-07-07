function u =group2(X, lu, i, Fi, CR, N, dim, paraIndex, index_best, deta_k);

if rand < 0.5
    
    %.... "current-to-best" ....%
    
    % Choose the indices for mutation
    indexSet = 1 : N;
    indexSet(i) = [];
    
    % Choose the first Index
    temp = floor(rand * (N - 1)) + 1;
    index(1) = indexSet(temp);
    indexSet(temp) = [];
    
    % Choose the second index
    temp = floor(rand * (N - 2)) + 1;
    index(2) = indexSet(temp);
    indexSet(temp) = [];
    
    % Choose the third index
    temp = floor(rand * (N - 3)) + 1;
    index(3) = indexSet(temp);
    
    % Mutation
    v1 = X(i, :) +  Fi.*deta_k+ Fi .* (X(index(1), :) - X(index(2), :));
  

    v1 = boundConstraint1 (v1, X(i, :), [lu(1,:);lu(2,:)]);
    % Binomial crossover
    j_rand = floor(rand * dim) + 1;
    t = rand(1, dim) < CR(paraIndex);
    t(1, j_rand) = 1;
    t_ = 1 - t;
    u = t .* v1 + t_ .* X(i, :);
  
else
    %... "current to rand/1" ...%

    index(1: 3) = floor(rand(1, 3) * N) + 1;
    
    % Mutation
    v2 = X(i, :) + rand * (X(index(1), :) - X(i, :)) + Fi .* (X(index(2), :) - X(index(3), :));
    v2 = boundConstraint1 (v2, X(i, :), [lu(1,:);lu(2,:)]);
    % Binomial crossover is not used to generate the trial vector under this
    % condition
    u = v2;
end
