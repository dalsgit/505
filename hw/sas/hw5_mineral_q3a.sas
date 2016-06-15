options ls=78;
title "Paired Hotelling's T-Square";
data mineral;
  infile "x:\505\hw5_mineral.dat";
  input dradius radius dhumerus humerus dulna ulna;
  d1=dradius - radius;
  d2=dhumerus - humerus;
  d3=dulna - ulna;
  run;
proc print;
  run;
proc iml;
  start hotel;
    mu0={0, 0, 0};
    one=j(nrow(x),1,1);
    ident=i(nrow(x));
    ybar=x`*one/nrow(x);
    s=x`*(ident-one*one`/nrow(x))*x/(nrow(x)-1.0);
    print mu0 ybar;
    print s;
    t2=nrow(x)*(ybar-mu0)`*inv(s)*(ybar-mu0);
    f=(nrow(x)-ncol(x))*t2/ncol(x)/(nrow(x)-1);
    df1=ncol(x);
    df2=nrow(x)-ncol(x);
    p=1-probf(f,df1,df2);
    print t2 f df1 df2 p;
  finish;
  use mineral;
  read all var{d1 d2 d3} into x;
  run hotel;



