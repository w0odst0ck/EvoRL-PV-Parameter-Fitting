function [position, value] = RLDE (N, range, dim, Max_iter, NEF, fobj)
    disp('RLDE is now estimating the global optimum for your problem....')    
    NP = N;
    CR = 0.9;
    FES = 0;
    lu = range;
    LB = range(1,:);
    UB = range(2,:);
    Nvars = dim;
    % Initialize the main population

    X = repmat(lu(1, :), NP, 1) + rand(NP, dim) .* (repmat(lu(2, :) - lu(1, :), NP, 1));
     
     fit = zeros(1,NP);
     
     for i=1:NP
        fit(i) = fobj(X(i,:));
         FES = FES+1;
     end
     
     [sorted,indices] = sort(fit);
     
     finalX = X(indices(1),:);
     finalY = sorted(1);
     
     A_G=[];
     G=1;
     
     
     %% =============================================
     State_pop=2*ones(NP,1); 
     Action_pop=zeros(size(State_pop)); 
     trial_State=State_pop;
     
     alp=0.1; %Q-learing rate
     gamma = 0.9; 
     Q_Agent=zeros(2.*NP,3);

     F=ones(NP,1)*normrnd(0.5,0.3);
     
     ftem=[-0.1,0,0.1]; % F-0.05；F+0；F+0.05
     b=ftem(randperm(length(ftem)));
     f=b(1);
     
     R=zeros(NP,1);
     %%===================================================================
     num_F=0;
     %% loop
      while FES < NEF 
 
          for i=1:NP
                
           if G<2
              r1 = randi(NP);
              while r1==i
                  r1 = randi(NP);
              end
              
              r2 = randi(NP);
              while r2==i || r2==r1
                  r2 = randi(NP);
              end
              
              r3 = randi(NP);
              while r3==i || r3==r1 || r3==r2
                  r3 = randi(NP);
              end
              
              deta_k=(X(r2,:)-X(r3,:));
                    
           else
                  
                  r1 = randi(NP);
                  while r1==i
                      r1 = randi(NP);
                  end
                  
                  if rand<=0.5

                      deta_k = A_G(randi(length(A_G)),:);
                  else 
                      r2 = randi(NP);
                      while r2==i || r2==r1
                          r2 = randi(NP);
                      end

                      r3 = randi(NP);
                      while r3==i || r3==r1 || r3==r2
                          r3 = randi(NP);
                      end
                  
                        deta_k=(X(r2,:)-X(r3,:));
 
                  end
           end
  
           %%==========F===================
           F(i)=F(i)+f;
           
           if F(i)>=1| F(i)<=0
                F(i)=normrnd(0.5,0.3);
               num_F=num_F+1;
           end
                [sorted1,indices1] = sort(fit);
                V(i,:) =  X(indices1(1),:)+F(i).*deta_k;
              jrand = randi(Nvars);
              for j=1:Nvars
                  if rand<=CR || j==jrand
                      New_X(i,j) = V(i,j);
                  else
                      New_X(i,j) = X(i,j);
                  end
              end
              
              for j=1:Nvars
                  if New_X(i,j)<LB(j)
                      New_X(i,j) = LB(j)+rand*(UB(j)-LB(j));
                  end
                  
                  if New_X(i,j)>UB(j)
                      New_X(i,j) = LB(j)+rand*(UB(j)-LB(j));
                  end
              end
              
              
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
          
             New_fit(i) = fobj(New_X(i,:));
               %   New_fit(i) = PV_TestFunction_29_s(type,New_X(i,:));
              FES = FES + 1;
              
              if New_fit(i)<fit(i)
                 A_G(size(A_G,1)+1,:) = New_X(i,:)-X(i,:);
                                 
                  X(i,:) = New_X(i,:);
                  fit(i) = New_fit(i);
                  R(i)=1;
                  trial_State(i,:)=1; 
              else
                  R(i)=0;
                  trial_State(i,:)=2;  
              end
              
          end
         
               %% 
          for kp=1:NP
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
          
          if length(A_G)>NP
             aa = randperm(length(A_G));
             bb = size(A_G,1)-NP;
             A_G(aa(1:bb),:) = [];
          end
          
          
          [sorted,indices] = sort(fit);
          
          finalX = X(indices(1),:);
          finalY = sorted(1);
          
      end
      position = finalX;
      value = finalY;
end
