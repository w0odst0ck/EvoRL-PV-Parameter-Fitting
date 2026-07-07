function [position, value] = SERLDE (N, range, dim, Max_iter, NEF, fobj)
    disp('SERLDE is now estimating the global optimum for your problem....')    

    %RLDE:CR = 0.9;
    CR = [0.1 0.9 0.2];
    FES = 0;
    lu = range;
    LB = range(1,:);
    UB = range(2,:);
    uSet = zeros(N, dim);

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
     G=0;
     
     
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

          for i=1:N
           
           %%==========F===================
           F(i)=F(i)+f;
           
           if F(i)>=1| F(i)<=0
                F(i)=normrnd(0.5,0.3);
               num_F=num_F+1;
           end
           
           if G<2
              r1 = randi(N);
              while r1==i
                  r1 = randi(N);
              end
              
              r2 = randi(N);
              while r2==i || r2==r1
                  r2 = randi(N);
              end
              
              r3 = randi(N);
              while r3==i || r3==r1 || r3==r2
                  r3 = randi(N);
              end
              
              deta_k=(X(r2,:)-X(r3,:));
              [sorted1,indices1] = sort(fit);
              uSet(i,:) =  X(indices1(1),:)+F(i).*deta_k;      
           else
                  

            % Uniformly and randomly select one of the control
            % parameter settings for each trial vector generation strategy
            paraIndex = floor(rand * length(CR)) + 1;

            if rand > FES / NEF
                % Generate the trial vectors by the group1
                u = group3(X, lu, i, F(i), CR, N, dim, paraIndex);
            else
                % Generate the trial vectors by the group1
                [~, best_index] = min(fit);
                deta_k = A_G(randi(length(A_G)),:);
                u = group4(X, lu, i, F(i), CR, N, dim, paraIndex, best_index, deta_k);
            end

            uSet(i, :) = u;
           end
  
%            %%==========F===================
%            F(i)=F(i)+f;
%            
%            if F(i)>=1| F(i)<=0
%                 F(i)=normrnd(0.5,0.3);
%                num_F=num_F+1;
%            end
             
              
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
          
             New_fit(i) = fobj(uSet(i,:));
             
              FES = FES + 1;
              
              if New_fit(i)<fit(i)
                  A_G(size(A_G,1)+1,:) = uSet(i,:)-X(i,:);
                                 
                  xTemp(i,:) = uSet(i,:);
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
          
          finalX = X(indices(1),:);
          finalY = sorted(1);
          
      end
      position = finalX;
      value = finalY;
end
