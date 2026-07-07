
x = [1, 2, 3, 4, 5]; 
R_s = 3.245; 
R_L = 23.1; 
V_oc = 19.6; 
ref_time = 0:0.1:10; 
ref_step = sin(ref_time); 


out = FO_Load_current_step(x, R_s, R_L, V_oc, ref_time, ref_step);


disp(out);
