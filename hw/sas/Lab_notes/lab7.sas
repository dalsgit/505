/*
Pottery shards are collected from four sites in the British Isles:
L: Llanedyrn
C: Caldicot
I: Isle Thorns
A: Ashley Rails

Each pottery sample was returned to the laboratory for chemical assay. 
In these assays the concentrations of five different chemicals were determined:
Al: Aluminum
Fe: Iron
Mg: Magnesium
Ca: Calcium
Na: Sodium
*/

options ls=78;
data pottery;
  infile "v:\505\datasets\pottery.dat";
  input site $ al fe mg ca na;
  run;

* assessing normality;
proc glm data=pottery;
  class site;
  model al fe mg ca na = site;
  output out=resids r=ral rfe rmg rca rna;
  run; quit;
proc univariate noprint data=resids;
  histogram ral rfe rmg rca rna;
  run;

* assessing constant covariance matrices;
proc sort data=resids;
  by site;
  run;
proc corr cov;
  by site;
  var ral rfe rmg rca rna;
  run;
proc discrim data=pottery pool=test;
  class site;
  var al fe mg ca na;
  run;

* profile plots;
* looking for evidence of multiple lines (groups);
data pottery2;
  set pottery;
  chemical="al"; amount=al; output;
  chemical="fe"; amount=fe; output;
  chemical="mg"; amount=mg; output;
  chemical="ca"; amount=ca; output;
  chemical="na"; amount=na; output;
  run;
proc sort data=pottery2;
  by site chemical;
  run;
proc means data=pottery2;
  by site chemical;
  var amount;
  output out=a mean=mean;
proc gplot data=a;
  axis1 length=3 in;
  axis2 length=4.5 in;
  plot mean*chemical=site / vaxis=axis1 haxis=axis2;
  symbol1 v=J f=special h=2 l=1 i=join color=black;
  symbol2 v=K f=special h=2 l=1 i=join color=black;
  symbol3 v=L f=special h=2 l=1 i=join color=black;
  symbol4 v=M f=special h=2 l=1 i=join color=black;
  run;

* manova overall test, also gives univariate anova results;
proc glm data=pottery;
  class site;
  model al fe mg ca na = site;
  manova h=site / printe printh;
  run; quit;

* contrasts for combinations of groups;
proc glm data=pottery;
  class site;
  model al fe mg ca na = site / clparm alpha=.00333;
  contrast 'C+L-A-I' site  8 -2  8 -14;
  contrast 'A vs I ' site  1  0 -1   0;
  contrast 'C vs L ' site  0  1  0  -1;
  estimate 'C+L-A-I' site  8 -2  8 -14/ divisor=16;
  estimate 'A vs I ' site  1  0 -1   0;
  estimate 'C vs L ' site  0  1  0  -1;
  lsmeans site / stderr cl pdiff;
  manova h=site / printe printh;
  run; quit;
