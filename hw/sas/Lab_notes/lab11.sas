*in-class example;
data rmatrix(type=corr);
  input _type_ $ m p c e h f;
  cards;
corr  1      .62  .54   .32   .284  .37
corr  .62  1     .51   .38   .351  .43
corr  .54   .51 1      .36   .336  .405
corr  .32   .38  .36  1      .686  .73
corr  .284  .351 .336  .686 1      .735
corr  .37   .43  .405  .73   .735 1
n  200 200 200 200 200 200
; run;
proc princomp data=rmatrix;
  var m p c e h f;
  run;
proc factor data=rmatrix method=principal rotate=varimax;
  var m p c e h f;
  run;
proc factor data=rmatrix method=ml rotate=varimax nfactors=2;
  var m p c e h f;
  run;

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
options ls=78 formdlim ='o' ;
data places;
  infile "v:\505\datasets\places.dat";
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
*PCA approach;
proc corr data=places noprint cov out=corr_out;
  var climate housing health crime trans educate arts recreate econ;
  run;
proc iml;
  use corr_out;
  read all var _NUM_ where(_TYPE_="CORR") into R;
  lambda=eigval(R);
  E=eigvec(R); *columns are eigenvectors;
  print lambda E;
  L1=sqrt(lambda[1])*E[,1];
  L2=sqrt(lambda[2])*E[,2];
  L3=sqrt(lambda[3])*E[,3];
  L=L1||L2||L3;
  print L; *factor loadings such that X = LF + epsilon;
  var1=sum(L[,1]#L[,1]); *variance explained by first factor;
  com1=sum(L[1,]#L[1,]); *communality for first variable;
  print var1 com1;
  quit;
proc factor data=places outstat=fa_out score method=principal scree 
	rotate=varimax ev residual;*plot nfactors=2 ;
  var climate housing health crime trans educate arts recreate econ;
  run;
proc score data=places score=fa_out out=scores;
  run;
proc print data=scores;
  var factor1-factor3;
  run;

*printing factor scores;
proc iml;
  use fa_out;
  read all var _NUM_ where(_TYPE_="UNROTATE") into L;
  read all var _NUM_ where(_TYPE_="TRANSFOR") into R;
  R=R[,1:3];
  L2=t(L)*t(R);
  print L2;
  use corr_out;
  read all var _NUM_ where(_TYPE_="MEAN") into xbar;
  read all var _NUM_ where(_TYPE_="COV") into S;
  use places;
  read all var {climate housing health crime trans educate arts recreate econ} into X[colname=varnames];
  z=(x-xbar)/t(sqrt(vecdiag(S)));
  scores=t(inv(t(L2)*L2)*t(L2)*t(z));
  print scores; *rotated factor scores;
  quit;

*ML approach;
proc factor data=places method=ml hey
	rotate=varimax residual nfactors=3 score out=mlscores;
  var climate housing health crime trans educate arts recreate econ;
  run;
proc print data=mlscores; 
  var factor1-factor3;
  run;
