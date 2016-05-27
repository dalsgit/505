data companies;
	infile "x:\505\hw2_companies.dat";
	input sales profits;
run;

*univariate;
title 'QQ univariate plot';
proc univariate data=companies;
var sales;
qqplot / normal;
run;

proc univariate data=companies;
var profits;
qqplot / normal;
run;

*multivariate qq plot;
title 'QQ multivariate plot';

proc princomp data=companies std out=pcresult; 
  var sales profits;
  run;
data mahal;
set pcresult;
dist2=uss(of prin1-prin2); *these are the squared statistial distances;
run;

proc print;
var dist2;
run;

proc sort;
	by dist2;
run;

data plotdata;
set mahal;
numberOfRows = 10;
p = 2;
prb=(_n_ -.5)/numberOfRows;
chiquant=cinv(prb, p); *chisq quantiles for plotting;
run;
proc gplot;
plot dist2*chiquant;
run;
title '';
quit;
