%let p=2;
data water;
	infile "x:\505\hw3_water.dat" firstobs=2;
	input trt y1 y2;
  variable="oxygen_demand"; x=y1; output;
  variable="suspended_solids";    x=y2;    output;
  keep variable x;
  run;
proc sort;
  by variable;
  run;
proc means;
  by variable;
  var x;
  output out=a n=n mean=xbar var=s2;
  run;

data b;
  set a;
  t1=tinv(1-0.025,n-1);
  tb=tinv(1-0.025/&p,n-1);
  f=finv(0.95,&p,n-&p);
  loone=xbar-t1*sqrt(s2/n);
  upone=xbar+t1*sqrt(s2/n);
  lobon=xbar-tb*sqrt(s2/n);
  upbon=xbar+tb*sqrt(s2/n);
  losim=xbar-sqrt(&p*(n-1)*f*s2/(n-&p)/n);
  upsim=xbar+sqrt(&p*(n-1)*f*s2/(n-&p)/n);
    run;
proc print;
  run;  
  
proc corr data=water plots(maxpoints=75000)=matrix;
	var y1 y2;
run;  