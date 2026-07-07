function u =group2(p, lu, i, F, CR, popsize, n, paraIndex,index_best);

if rand < 0.5
    
    %.... "current-to-best" ....%
    
    % Choose the indices for mutation
    indexSet = 1 : popsize;
    indexSet(i) = [];
    
    % Choose the first Index
    temp = floor(rand * (popsize - 1)) + 1;
    index(1) = indexSet(temp);
    indexSet(temp) = [];
    
    % Choose the second index
    temp = floor(rand * (popsize - 2)) + 1;
    index(2) = indexSet(temp);
    indexSet(temp) = [];
    
    % Choose the third index
    temp = floor(rand * (popsize - 3)) + 1;
    index(3) = indexSet(temp);
    
    % Mutation
    v1 = p(i, :) +  F(paraIndex).*(p(index_best,:)-p(i,:))+ F(paraIndex) .* (p(index(1), :) - p(index(2), :));
  

    v1 = boundConstraint1 (v1, p(i, :), [lu(1,:);lu(2,:)]);
    % Binomial crossover
    j_rand = floor(rand * n) + 1;
    t = rand(1, n) < CR(paraIndex);
    t(1, j_rand) = 1;
    t_ = 1 - t;
    u = t .* v1 + t_ .* p(i, :);
  
else
    %... "current to rand/1" ...%

    index(1: 3) = floor(rand(1, 3) * popsize) + 1;
    
    % Mutation
    v2 = p(i, :) + rand * (p(index(1), :) - p(i, :)) + F(paraIndex) .* (p(index(2), :) - p(index(3), :));
    v2 = boundConstraint1 (v2, p(i, :), [lu(1,:);lu(2,:)]);
    % Binomial crossover is not used to generate the trial vector under this
    % condition
    u = v2;
end
