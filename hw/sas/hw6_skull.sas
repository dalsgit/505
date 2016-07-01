options ls=78;
title "Check for normality";
data pottery;
  infile "x:\505\hw6_skulls.dat";
  input X1 X2 X3 X4 period;
  run;
proc glm;
  class period;
  model  X1 X2 X3 X4 = period;
  output out=resids r=rX1 rX2 rX3 rX4;
  run;
proc print;
  run;

proc univariate data=resids;
histogram rX1 rX2 rX3 rX4;
run;

proc corr data=resids plots=matrix;
var rX1 rX2 rX3 rX4;
run;

title "Bartlett's Test";
proc discrim pool=test;
  class period;
  var X1 X2 X3 X4;
  run;

title "MANOVA";
proc glm;
  class period;
  model X1 X2 X3 X4 = period;
  lsmeans period / stderr;
  manova h=period / printe printh;
  run;  
  
title "MANOVA with orthogonal contrasts";  
proc glm;
  class period;
  model X1 X2 X3 X4 = period;
  contrast '1+2-3' period  1  1  -2;
  contrast '1 vs 2' period  1  -1  0;
  estimate '1+2-3' period  1  1  -2/ divisor=2;
  estimate '1 vs 2' period  1  -1  0;
  lsmeans period / stderr;
  manova h=period / printe printh;
  run;  

title "MANOVA with non orthogonal contrasts";  
proc glm;
  class period;
  model X1 X2 X3 X4 = period;
  contrast '1 vs 2' period  1  -1  0;
  contrast '1 vs 3' period  1  0  -1;
  contrast '2 vs 3' period  0  1  -1;
  estimate '1 vs 2' period  1  -1  0;
  estimate '1 vs 3' period  1  0  -1;
  estimate '2 vs 3' period  0  1  -1;
  lsmeans period / stderr;
  manova h=period / printe printh;
  run;  