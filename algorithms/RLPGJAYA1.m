function [position, value] = RLPGJAVA1 (N, range, dim, Max_iter, NEF, fobj)
    disp('RLPGJAVA is now estimating the global optimum for your problem....')    

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
     
     A_G=[];
     G=1;
     
     M_X=rand;

     %% =============================================
     State_pop=2*ones(N,1); 
     Action_pop=zeros(size(State_pop)); 
     trial_State=State_pop;
     
     alp=0.1; %Q-learing rate
     gamma = 0.9; 
     Q_Agent=zeros(2.*N,3);

     F=ones(N,1)*normrnd(0.5,0.3);
     
     ftem=[-0.1,0,0.1]; % F-0.05；F+0；F+0.05
     b=ftem(randperm(length(ftem)));
     f=b(1);
     
     R=zeros(N,1);
     %%===================================================================
     num_F=0;
     
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
           
            %%==========F===================
            F(i)=F(i)+f;
            
            if F(i)>=1| F(i)<=0
                    F(i)=normrnd(0.5,0.3);
                num_F=num_F+1;
            end
           
            if rand>pp(i)    
                for j=1:dim
                    V(i,j) = X(i,j) + F(i)*(Best(j)-abs(X(i,j)))-ww*rand*(Worst(j) -abs(X(i,j)));
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
                V(i,:) = X(i,:) + F(i)*(X(nouse1(1),:) -X(nouse1(2),:)); 
            end
                
            V = boundConstraint_absorb(V, Xmin, Xmax);

             
              
     %% 
         Agent_current=X(i,:);
         Qtemp=Q_Agent(2*i-1:2*i,:);
         AgState=State_pop(i); 
         Qvalue1=Qtemp(AgState,:); 
         temp=exp(Qvalue1);
        
         ratio=cumsum(temp)/sum(temp); 
         jtemp=find(rand(1)<ratio);
         adjustment=jtemp(1);         %action:F 
         Action_pop(i)=adjustment;  
         
         switch adjustment
             case 1
                 f=-0.1;
             case 2
                 f=0;
             case 3
                 f =0.1;
         end

             New_fit(i) = fobj(V(i,:));
             
              FES = FES + 1;
              
              if New_fit(i)<fit(i)
                  A_G(size(A_G,1)+1,:) = V(i,:)-X(i,:);
                                 
                  xTemp(i,:) = V(i,:);
                  fitTemp(i) = New_fit(i);
                  R(i)=1;
                  trial_State(i,:)=1; 
              else
                  R(i)=0;
                  trial_State(i,:)=2;  
              end
              
          end

          X = xTemp;
          fit = fitTemp;
          record(G) = min(fit);
               %% 
          for kp=1:N
              Qtemp=Q_Agent(2*kp-1:2*kp,:);
              AgState=State_pop(kp);
              Action=Action_pop(kp);
              NextState=trial_State(kp); 
              temp=max(Qtemp(NextState,:));   
              Qtemp(AgState,Action)=(1-alp)*Qtemp(AgState, Action)+alp*(R(kp)+gamma*temp); 
              Q_Agent(2*kp-1:2*kp,:)=Qtemp;
              
          end
          State_pop=trial_State;
          
          total=[];
          total=A_G;
          
          if length(A_G)>N
             aa = randperm(length(A_G));
             bb = size(A_G,1)-N;
             A_G(aa(1:bb),:) = [];
          end
          
          
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
