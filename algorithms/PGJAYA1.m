function [position, value] = PGJAVA1 (N, range, dim, Max_iter, NEF, fobj)
    disp('PGJAVA is now estimating the global optimum for your problem....')    

    %RLDE:CR = 0.9;
    CR = [0.1 0.9 0.2];
    FES = 0;
    lu = range;
    Xmin = range(1,:);
    Xmax = range(2,:);


    % Initialize the main population

    X = repmat(lu(1, :), N, 1) + rand(N, dim) .* (repmat(lu(2, :) - lu(1, :), N, 1));
     
     fit = zeros(1,N);
     
     for i=1:N
        fit(i) = fobj(X(i,:));
         FES = FES+1;
     end
     
     [sorted,indices] = sort(fit);
     
     finalX = X(indices(1),:);
     finalY = sorted(1);

     G=1;
     
     M_X=rand;
     
     %% loop
      while FES < NEF 
          G = G + 1;
          xTemp = X;
          fitTemp = fit;
          New_fit = zeros(N, 1);
          Seq = 1:N;
          R = N-Seq;
          p = (R/N).^2;
          pp(indices)=p;
          Best = X(indices(1),:);
          Worst= X(indices(end),:);
        
        if fit(indices(end))==0
            ww=1;
        else
            ww=abs(fit(indices(1))/(fit(indices(end))))^2;
        end          

          for i=1:N
           
            if rand>pp(i)    
                for j=1:dim
                    V(i,j) = X(i,j) + rand*(Best(j)-abs(X(i,j)))-ww*rand*(Worst(j) -abs(X(i,j)));
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
                V(i,:) = X(i,:) + rand(1,dim).*(X(nouse1(1),:) -X(nouse1(2),:)); 
            end
                
            V = boundConstraint_absorb(V, Xmin, Xmax);

             New_fit(i) = fobj(V(i,:));
             
              FES = FES + 1;
              
              if New_fit(i)<fit(i)                         
                  xTemp(i,:) = V(i,:);
                  fitTemp(i) = New_fit(i);
              end
              
          end

          X = xTemp;
          fit = fitTemp;
          record(G) = min(fit);       
          
          [sorted,indices] = sort(fit);
          Best = X(indices(1),:);
          M_X=4*M_X*(1-M_X);
            for k=1:dim
                if rand<1-FES/NEF
                    newX(k)=Best(k)+rand*(2*M_X-1);
                else
                    newX(k)=Best(k);              
                end   
            end       
            newX = boundConstraint_absorb(newX, Xmin, Xmax);
            new_val = fobj(newX);
            FES = FES + 1;
            if new_val<fit(indices(end))  
                fit(indices(end)) = new_val;
                X(indices(end),:) = newX;
            end
          finalX = X(indices(1),:);
          finalY = sorted(1);
          
      end
      position = finalX;
      value = finalY;
end
