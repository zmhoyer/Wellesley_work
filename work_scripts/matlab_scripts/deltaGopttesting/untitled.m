%new script sad days

Cqrs=load("Cqrs.txt");
Cqrt=load("Cqrt.txt");
LL=load("Lmatrix.txt");
Lstqt=load("Lstqt.txt");
Ltt=load("Ltt.txt");
qLopt_6=load("qLopt_constraint_6.txt");
qLopt_7=load("qLopt_constraint_7.txt");
RDP=load("RDP.txt");

deltaG_opt_constraint_6 = (qLopt_6'*LL*qLopt_6)+(qLopt_6'*Cqrs)+(qLopt_6'*Lstqt)+(Ltt)+(Cqrt)+(RDP);
deltaG_opt_constraint_7 = (qLopt_7'*LL*qLopt_7)+(qLopt_7'*Cqrs)+(qLopt_7'*Lstqt)+(Ltt)+(Cqrt)+(RDP);

deltaG_6=load("deltaG_constraint_6.txt");
deltaG_7=load("deltaG_constraint_7.txt");


