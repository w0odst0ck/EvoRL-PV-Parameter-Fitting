function [ out ] = IO_Load_current_step( x,R_s,R_L,V_oc,ref_time,ref_step )

R_c=x(1);
C_alpha=x(2);
L_beta=x(3);


a11=-1/(C_alpha*(R_c+R_s));
a12=-R_s/(C_alpha*(R_c+R_s));
a21=R_s/(L_beta*(R_c+R_s));
a22=-(R_L*R_c+R_s*R_c+R_L*R_s)/(L_beta*(R_c+R_s));
b1=1/(C_alpha*(R_c+R_s));
b2=R_c/(L_beta*(R_c+R_s));
% A=[a11 a12;a21 a22];
% B=[b1;b2];
% sys=ss(A,B,[0 1],0);
% sys2=tf(sys);

 tf2=tf([a21+b2,a21*b1-a11*b2],[1,-a11-a22,a11*a22-a12*a21]);

    
    Y=step(tf2,ref_time);
    Y=Y*V_oc;% compensate for non-unity step
%     out=abs(Y'-ref_step);
out=Y'-ref_step;
% out=1e5*ref_time.*(Y'-ref_step);
    
end

