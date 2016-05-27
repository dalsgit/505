options ls=78;
title "Q2";
data n1;
  input x1 x2 x3;
  datalines;
1 4 3
6 2 6
8 3 3	
;

proc means;
  var x1 x2 x3;
  run;
proc corr pearson cov;
  var x1 x2 x3;
  run;