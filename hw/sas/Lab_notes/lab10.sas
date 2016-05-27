/*
We will use the Places Rated Almanac data (Boyer and Savageau) which rates 329 communities according to nine criteria:
  Climate and Terrain
  Housing
  Health Care & Environment
  Crime
  Transportation
  Education
  The Arts
  Recreation
  Economics
Notes:
  The data for many of the variables are strongly skewed to the right.
  The log transformation was used to normalize the data.
*/
options ls=78;
title "PCA - Covariance Matrix - Places Rated";
data places;
  infile 'v:\505\datasets\places.dat';options ls=78;
  input climate housing health crime trans educate arts recreate econ id;
  climate=log10(climate);
  housing=log10(housing);
  health=log10(health);
  crime=log10(crime);
  trans=log10(trans);
  educate=log10(educate);
  arts=log10(arts);
  recreate=log10(recreate);
  econ=log10(econ);
  run;
* manual approach;
proc corr data=places cov noprob out=corr_out;
  var climate housing health crime trans educate arts recreate econ;
  run;
proc iml;
  use corr_out;
  read all var _NUM_ where(_TYPE_="MEAN") into xbar;
  read all var _NUM_ where(_TYPE_="COV") into S;
  read all var _NUM_ where(_TYPE_="CORR") into R;
  lambda_S=eigval(S);
  lambda_R=eigval(R);
  e_S=eigvec(S);
  e_R=eigvec(R);
  print lambda_S lambda_R e_S e_R;

  use places;
  read all var {climate housing health crime trans educate arts recreate econ} into x[colname=varnames];
  print x;
  c=(x-xbar); *centered values;
  z=c/t(sqrt(vecdiag(S))); *standardized values;
  y_S=x*e_S; *principal components for sample covariance matrix;
  y_c=c*e_S; *SAS outputs these as sample principal components;
  y_R=z*e_R; *principal components for sample correlation matrix;
  print y_S y_c y_R;
  quit;

* SAS approach (un-standardized);
* default is to do pca on the correlation matrix, the cov option specifies covariance matrix;
proc princomp data=places cov out=a;
  var climate housing health crime trans educate arts recreate econ;
  run;
proc print data=a; 
  var prin1-prin9; *these correspond to the y_c values;
  run;
proc corr data=a;
  var prin1 prin2 prin3 climate housing health crime trans educate arts 
      recreate econ;
  run;
proc gplot data=a;
  axis1 length=5 in;
  axis2 length=5 in;
  plot prin2*prin1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=none color=black;
  run;

* SAS approach (standardized);
title "PCA - Correlation Matrix - Places Rated";
proc princomp data=places out=b;
  var climate housing health crime trans educate arts recreate econ;
  run;
proc print data=b; 
  var prin1-prin9; *these correspond to the y_r values;
  run;
proc corr data=b;
  var prin1 prin2 prin3 climate housing health crime trans educate arts 
      recreate econ;
  run;
proc gplot;
  axis1 length=5 in;
  axis2 length=5 in;
  plot prin2*prin1 / vaxis=axis1 haxis=axis2;
  symbol v=J f=special h=2 i=none color=black;
  run;
