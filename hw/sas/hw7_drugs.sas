options ls=78;
title "Drugs Data";
data dogs;
  infile "x:\505\hw7_drugs.dat";
  input person h1 h2 h3 h4 treat $;
  run;
proc print;
  run;
  
proc glm;
  class treat;
  model h1 h2 h3 h4=treat;
  manova h=treat / printe;
  manova h=treat m=h1+h2+h3+h4;
  manova h=treat m=h2-h1,h3-h2,h4-h3;
  run;  

title "Check for normality - Drugs Data";
proc glm;
  class treat;
  model h1 h2 h3 h4=treat;
  output out=resids r=rh1 rh2 rh3 rh4;
  run;
proc print;
  run;  
  
proc univariate data=resids;
histogram rh1 rh2 rh3 rh4;
run;

proc corr data=resids plots=matrix;
var rh1 rh2 rh3 rh4;
run;  

title "Bartlett's Test";
proc discrim pool=test;
  class treat;
  var h1 h2 h3 h4;
  run;