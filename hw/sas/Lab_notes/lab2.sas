/* introduction to proc iml */
options ls=78;
title '505 lab, 9/5'; 

proc iml;
  a = 2; *scalar;
  b = {1 2 3}; *1x3 matrix (row vector);
  c = {1 2 3, 4 5 6}; *2x3 matrix;
  d = a*b+c[2,]; *element-wise operations;
  e = b#d; *element-wise multiplication;
  f = b*t(c); *matrix multiplication: b by transpose of c;
  print a b c d e f;
  quit;

data nutrient;
  infile "v:\505\datasets\nutrient.txt";
  input id calcium iron protein a c;
  run;

* direct computation of |S| from X;
proc iml;
  use nutrient; *allows access to all variables in the nutrient dataset;
  read all var{calcium iron protein a c} into x; *x matrix has columns calcium, iron, etc;
  n = nrow(x); *number of observations;
  one = j(n,1,1); *j is constant matrix with n rows, 1 column, and each element is 1;
  xbar = (1/n)*t(x)*one; *5x1 vector of sample means; 
  s = (1/(n-1))*t(x-one*t(xbar))*(x-one*t(xbar)); *5x5 sample covariance matrix;
  genvar = det(s); *generalized variance = determinant of s;
  print xbar s genvar;
  quit;

* computation of |S| from existing S;
proc corr data=nutrient nocorr nosimple cov out=output; *saves the covariance matrix;
  var calcium iron protein a c;
  run;
proc print data=output (where=(_TYPE_="COV"));
  var calcium iron protein a c;
  run;
proc iml;
  use output where(_TYPE_="COV");
  read all var _NUM_ into s[colname=varNames];
  genvar=det(s);
  print genvar;
  quit;

* using modules (without arguments);
proc iml;
  a = 1;
  start mod1; *begin module definition;
    a = 2; *overwrites the global definition of a;
	print a;
    finish mod1; *end the module definition;
  run mod1; *will print a=2;
  print a; *will print a=2;
  quit;

* using modules (with arguments);
proc iml;
  a = 1;
  start mod2(x); *begin module definition with argument x;
    a = 2; *this variable defined locally;
	print a;
	x = 3;
    finish mod2; *end the module definition;
  run mod2(1); *will print local a=2;
  print a; *will print a=1;
  run mod2(a); *will print local a=2 and reassign 3 to global a;
  print a; *will print a=3;
  quit;

* using modules (with return);
proc iml;
  start mod3(x); *begin module definition with argument x;
    x = x + 2;
	return(x);
    finish mod3; *end the module definition;
  y1 = mod3(1);
  y2 = mod3(2);
  y3 = mod3(3);
  print y1 y2 y3;
  quit;

* some misc functions;
proc iml;
  a = I(3); *3x3 identity matrix;
  b = diag({1 2 3}); *3x3 matrix with 1 2 3 on the diagonal;
  c = inv(b); *matrix inverse;
  d = b*c; *should equal the identity;
  e = trace(b); *sum of the diagonal elements;
  print a b c d e;
  quit;
