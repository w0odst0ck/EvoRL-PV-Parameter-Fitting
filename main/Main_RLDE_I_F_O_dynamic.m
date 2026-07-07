clc
clear
%% Add paths
addpath(genpath('../algorithms'));
addpath(genpath('../model'));
addpath(genpath('../utils'));
addpath(genpath('../fomcon-1.21b/1.21b'));
% 
%% 
% The code of the manuscript of 
% 1-* Yousri, D., Allam, D., Eteiba, M.B. and Suganthan, P.N., 2019. Static and dynamic photovoltaic models’ parameters identification using Chaotic Heterogeneous 
% Comprehensive Learning Particle Swarm Optimizer variants.  Energy
% conversion and management, 182, pp.546-563. For integer and fractional
% order dynamic models 

% Based on the model of 
%1- AbdelAty, A.M., Radwan, A.G., Elwakil, A. and Psychalinos, C., 2016, June. A fractional-order dynamic PV model. 
% In 2016 39th International Conference on Telecommunications and Signal Processing (TSP) (pp. 607-610). IEEE.

% 2- AbdelAty, A.M., Radwan, A.G., Elwakil, A.S. and Psychalinos, C., 2018. Transient and steady-state response of a fractional-order dynamic PV model under different loads.
% Journal of Circuits, Systems and Computers, 27(02), p.1850023.

% If you use the codes of the models , pls you should cite the emntioned
% manuscripts.
%% 
%data from figure 5 2011 paper
M = dlmread('../data/Load_current_2011_paper_big_time.csv');
data_length=length(M(:,1));
fit_length=data_length;
tim_raw=M(1:fit_length,1);
I_Load_raw=M(1:fit_length,2);

[C,ia,idx] = unique(tim_raw,'stable');
val = accumarray(idx,I_Load_raw,[],@mean);
M_new = [C val];

inter_step=1e-8;
tim=0:inter_step:17.5e-6;
I_Load_inter=interp1(M_new(:,1),M_new(:,2),tim);

% plot(M(:,1),M(:,2),'o') hold all plot(M_new(:,1),M_new(:,2))
% plot(tim,I_Load_inter) hold off


% integer data 2011 paper
R_c=9.56;
C=256.92e-9;
L=9.52e-6;
%first experiment at G=655w/m^2
V_oc=19.6;
R_s=3.245;
R_L=23.1;

i_inf=0.712;
% R_s=V_oc/i_inf-R_L;
V_oc=(R_s+R_L)*i_inf;

% ss_current=V_oc/(R_s+R_L)

a11=-1/(C*(R_c+R_s));
a12=-R_s/(C*(R_c+R_s));
a21=R_s/(L*(R_c+R_s));
a22=-(R_L*R_c+R_s*R_c+R_L*R_s)/(L*(R_c+R_s));
b1=1/(C*(R_c+R_s));
b2=R_c/(L*(R_c+R_s));
% 
%% To run integer order model select the objective function (root mean square or sum absolute error )
%fobj=@(x)sum(abs(IO_Load_current_step(x,R_s,R_L,V_oc,tim,I_Load_inter)));
%
% fobj=@(x)rms((IO_Load_current_step(x,R_s,R_L,V_oc,tim,I_Load_inter)));
% lb=[0.00001,20e-9,5e-6];
% ub=[20,600e-7,100e-6];
%% To run fractional order model select the objective function (root mean square or sum absolute error )
%fobj=@(x)sum(abs(FO_Load_current_step(x,R_s,R_L,V_oc,tim,I_Load_inter)));
fobj=@(x)rms((FO_Load_current_step(x,R_s,R_L,V_oc,tim,I_Load_inter)));
 lb=[0.00001,20e-9,5e-6,0.8,0.8];
 ub=[20,600e-7,100e-6,1.1,1.1];
% 
%% Main
Number_of_runs=30;
N=30; % Number of search agents
Max_iter=200;% This should be equal or greater than OPTIONS.Maxgen in Init.m file
NEF=20000;
range= [lb; ub];
dim=length(lb);
for j=1:Number_of_runs
    tic;
   [Best_pos(j,:),Best_score(j)]=RLDE(N , range ,dim,Max_iter,NEF,fobj);   
   RLDE_time(j)=toc;
  end
save('../data/RLDE_FO_dynamic') % save results of the fractional order model

%save('../data/RLDE_IO_dynamic') % save results of the integer order model
% % %
%% For Integer order m  model
% 
% load('../data/RLDE_IO_dynamic.mat')
% [Mm  II]=min(Best_score);
% Mm_std=std(Best_score);
% x=Best_pos(II,:);
% R_c=x(1); C_alpha=x(2); L_beta=x(3);
% a11=-1/(C_alpha*(R_c+R_s)); a12=-R_s/(C_alpha*(R_c+R_s));
% a21=R_s/(L_beta*(R_c+R_s));
% a22=-(R_L*R_c+R_s*R_c+R_L*R_s)/(L_beta*(R_c+R_s));
% b1=1/(C_alpha*(R_c+R_s)); b2=R_c/(L_beta*(R_c+R_s));
% tf2=tf([a21+b2,a21*b1-a11*b2],[1,-a11-a22,a11*a22-a12*a21]);
% Y2=step(tf2,tim); Y2=Y2*V_oc;% compensate for non-unity step
% 
A_L=0.762; A_C=0.05; i_inf=0.712; T_c=3.186e-6;
T_l=0.373e-6;
% i_load_integer=-A_L*exp(-tim/T_l)+A_C*exp(-tim/T_l)+i_inf;
% RLDE_IO_rms=rms (I_Load_inter-Y2');
% inte  =rms (I_Load_inter-i_load_integer) ;
% % % % % 
%% For fractional oder model 
load('../data/RLDE_FO_dynamic.mat')
[Mm  II]=min(Best_score);
Mm_std=std(Best_score);
x=Best_pos(II,:);
R_c=x(1); C_alpha=x(2); L_beta=x(3); alpha=x(4); bet=x(5);
a11=-1/(C_alpha*(R_c+R_s));
a12=-R_s/(C_alpha*(R_c+R_s));
a21=R_s/(L_beta*(R_c+R_s));
a22=-(R_L*R_c+R_s*R_c+R_L*R_s)/(L_beta*(R_c+R_s));
b1=1/(C_alpha*(R_c+R_s));
b2=R_c/(L_beta*(R_c+R_s));

tf2=fotf([1,-a11,-a22,a11*a22-a12*a21]...
    ,[alpha+bet,bet,alpha,0],[a21+b2,a21*b1-a11*b2]...
    ,[alpha,0]);

Y2=step(tf2,tim);
Y2=Y2*V_oc;% compensate for non-unity step
i_load_integer=-A_L*exp(-tim/T_l)+A_C*exp(-tim/T_l)+i_inf;
RLDE_FO_rms=rms (I_Load_inter-Y2');
Frac  =rms (I_Load_inter-i_load_integer) ;

