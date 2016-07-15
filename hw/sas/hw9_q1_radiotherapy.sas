options ls=78;
title "PCA - radiotherapy";
data places;
  infile "x:\505\hw9_radiotherapy.dat";
  input X1 X2 X3 X4 X5 X6;
  run;
/* Part a - covariance and correlation matrices S and R */
proc corr pearson cov;
  var X1 X2 X3 X4 X5 X6;
  run;

/* Principal Components using R matrix */
proc princomp out=a;
  var X1 X2 X3 X4 X5 X6;
  run;

/* Use first 3 components - their correlation */  
proc corr;
  var prin1 prin2 prin3 X1 X2 X3 X4 X5 X6;
  run;
  quit;