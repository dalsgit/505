options ls=78;
title "PCA - track";
data places;
	infile "x:\505\hw9_track.dat";
	input d100 d200 d400 d800 d1500 d5000 d10000 marathon country $;
	d100=d100/60;
	d200=d200/60;
	d400=d400/60;
	run;

/* Principal Components using S covariance matrix */
proc princomp cov out=s;
  var d100 d200 d400 d800 d1500 d5000 d10000 marathon;
  run;

proc gplot data=s;
  axis1 length=5 in;
  axis2 length=5 in;
  plot prin2*prin1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=none color=black;
  run;
  
/* Principal Components using R correlation matrix */
proc princomp out=r;
  var d100 d200 d400 d800 d1500 d5000 d10000 marathon;
  run;

proc gplot data=r;
  axis1 length=5 in;
  axis2 length=5 in;
  plot prin2*prin1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=none color=black;
  run;