data air;
	infile "x:\505\hw3_air.dat";
	input wind solar CO NO NO2 O3 HC;
run;

*univariate;
title 'QQ univariate plot - solar';
proc univariate data=air;
var solar;
qqplot / normal;
run;

title 'QQ univariate plot - CO';
proc univariate data=air;
var CO;
qqplot / normal;
run;

title 'QQ univariate plot - NO2';
proc univariate data=air;
var NO2;
qqplot / normal;
run;


*multivariate qq plot;
title 'QQ multivariate plot';

proc princomp data=air std out=pcresult; 
  var solar CO NO2;
  run;
data mahal;
set pcresult;
dist2=uss(of prin1-prin3); *these are the squared statistical distances;
run;

proc print;
var dist2;
run;

proc sort;
	by dist2;
run;

data plotdata;
set mahal;
numberOfRows = 42;
p = 3;
prb=(_n_ -.5)/numberOfRows;
chiquant=cinv(prb, p); *chisq quantiles for plotting;
run;
proc gplot;
plot dist2*chiquant;
run;
title '';
quit;

*Scatter plot;
title 'Scatter plot';
proc sgscatter data=air;
  title "Scatterplot Matrix";
  matrix solar CO NO2;
run;

proc corr data=air plots(maxpoints=75000)=matrix;
	var solar CO NO2;
run;