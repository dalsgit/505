
options ls=78;
data nutrient;
  infile "v:\505\datasets\nutrient.dat";
  input id calcium iron protein a c;
  run;

title "One sample Hotellings T2 and CIs - online example";
* hypothesis test;
proc iml;
  start hotel;
    mu0={1000, 15, 60, 800, 75};
    one=j(nrow(x),1,1);
    ident=i(nrow(x));
    xbar=x`*one/nrow(x);
    s=x`*(ident-one*one`/nrow(x))*x/(nrow(x)-1.0);
    print mu0 xbar;
    print s;
    t2=nrow(x)*(xbar-mu0)`*inv(s)*(xbar-mu0);
    f=(nrow(x)-ncol(x))*t2/ncol(x)/(nrow(x)-1);
    df1=ncol(x);
    df2=nrow(x)-ncol(x);
    pval=1-probf(f,df1,df2);
    print t2 f df1 df2 pval;
  finish;
  use nutrient;
  read all var{calcium iron protein a c} into x;
  run hotel;
  quit;
* confidence intervals;
%let p=5;
data nutrient2;
  infile "v:\505\datasets\nutrient.dat";
  input id calcium iron protein a c;
  variable="calcium"; x=calcium; output;
  variable="iron";    x=iron;    output;
  variable="protein"; x=protein; output;
  variable="vit a";   x=a;       output;
  variable="vit c";   x=c;       output;
  keep variable x;
  run;
proc sort;
  by variable;
  run;
proc means noprint;
  by variable;
  var x;
  output out=a n=n mean=xbar var=s2;
  run;
data b;
  set a;
  t1=tinv(1-0.025,n-1);
  tb=tinv(1-0.025/&p,n-1);
  f=finv(0.95,&p,n-&p);
  loone=xbar-t1*sqrt(s2/n);
  upone=xbar+t1*sqrt(s2/n);
  losim=xbar-sqrt(&p*(n-1)*f*s2/(n-&p)/n);
  upsim=xbar+sqrt(&p*(n-1)*f*s2/(n-&p)/n);
  lobon=xbar-tb*sqrt(s2/n);
  upbon=xbar+tb*sqrt(s2/n);
  run;
proc print;
  run;

title "One sample Hotellings T2 - alternate approach";
proc corr data=nutrient nocorr cov out=corr_out;
  var calcium iron protein a c;
  run;
proc iml;
  use corr_out;
  read all var _NUM_ where(_TYPE_="MEAN") into xbar[colname=varnames];
  read all var _NUM_ where(_TYPE_="COV") into S;
  read all var _NUM_ where(_TYPE_="N") into n;
  varnames=t(varNames);
  s2=vecdiag(S);
  n=n[1];
  p=nrow(s);
  xbar=t(xbar);
  * hypothesis test;
  mu0={1000, 15, 60, 800, 75};
  t2=n*t(xbar-mu0)*inv(s)*(xbar-mu0);
  f=t2*(n-p)/p/(n-1);
  pval=1-probf(f,p,n-p);
  print varnames xbar mu0;
  print t2 f pval;
  * confidence intervals;
  alpha = .05;
  t1=tinv(1-alpha/2,n-1);
  tb=tinv(1-alpha/2/p,n-1);
  f=finv(1-alpha,p,n-p);
  loone=xbar-t1*sqrt(s2/n);
  upone=xbar+t1*sqrt(s2/n);
  lobon=xbar-tb*sqrt(s2/n);
  upbon=xbar+tb*sqrt(s2/n);
  losim=xbar-sqrt(p*(n-1)*f*s2/(n-p)/n);
  upsim=xbar+sqrt(p*(n-1)*f*s2/(n-p)/n);
  print varNames loone upone lobon upbon losim upsim;
  /* 
   * confidence interval for a'mu = mu1+mu2+..+mu5;
  a={1,1,1,1,1};
  xbar_a=t(a)*xbar;
  s2_a=t(a)*s*a;
  losim_a=xbar_a-sqrt(p*(n-1)*f*s2_a/(n-p)/n);
  upsim_a=xbar_a+sqrt(p*(n-1)*f*s2_a/(n-p)/n);
  parameter = 'sum of means';
  null = t(a)*mu0;
  print parameter losim_a null upsim_a;
  */ 
  quit;

title "Paired Hotellings T2";
/*
On a scale of 1 to 5,
q1) What is the level of passionate love you feel for your partner?
q2) What is the level of passionate love your partner feels for you?
q3) What is the level of companionate love you feel for your partner?
q4) What is the level of companionate love your partner feels for you?
*/
data spouse;
  infile "v:\505\datasets\spouse.dat";
  input h1 h2 h3 h4 w1 w2 w3 w4;
  d1=h1-w1;
  d2=h2-w2;
  d3=h3-w3;
  d4=h4-w4;
  run;
proc iml;
  start hotel;
    mu0={0, 0, 0, 0};
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
  use spouse;
  read all var{d1 d2 d3 d4} into x;
  run hotel;
  quit;

title "Profile plots - online example";
%let p=5;
data nutrient3;
  infile "v:\505\datasets\nutrient.dat";
  input id calcium iron protein a c;
  variable="calcium"; ratio=calcium/1000; output;
  variable="iron";    ratio=iron/15;      output;
  variable="protein"; ratio=protein/60;   output;
  variable="vit a";   ratio=a/800;        output;
  variable="vit c";   ratio=c/75;         output;
  keep variable ratio;
  run;
proc sort;
  by variable;
  run;
proc means;
  by variable;
  var ratio;
  output out=a3 n=n mean=xbar var=s2;
  run;
data b3;
  set a3;
  f=finv(0.95,&p,n-&p);
  ratio=xbar; output;
  ratio=xbar-sqrt(&p*(n-1)*f*s2/(n-&p)/n); output;
  ratio=xbar+sqrt(&p*(n-1)*f*s2/(n-&p)/n); output;
  run;
proc gplot;
  axis1 length=4 in;
  axis2 length=6 in;
  plot ratio*variable / vaxis=axis1 haxis=axis2 vref=1 lvref=21;
  symbol v=none i=hilot color=black;
  run;

title "Profile plots - alternate approach";
data nutrient4;
  infile "v:\505\datasets\nutrient.dat";
  input id calcium iron protein a c;
  variable="calcium"; ratio=(calcium-1000)/sqrt(157829); output;
  variable="iron";    ratio=(iron-15)/sqrt(35.81);      output;
  variable="protein"; ratio=(protein-60)/sqrt(934.88);   output;
  variable="vit a";   ratio=(a-800)/sqrt(2668452);        output;
  variable="vit c";   ratio=(c-75)/sqrt(5416);         output;
  keep variable ratio;
  run;
proc sort;
  by variable;
  run;
proc means;
  by variable;
  var ratio;
  output out=a4 n=n mean=xbar var=s2;
  run;
data b4;
  set a4;
  f=finv(0.95,&p,n-&p);
  ratio=xbar; output;
  ratio=xbar-sqrt(&p*(n-1)*f*s2/(n-&p)/n); output;
  ratio=xbar+sqrt(&p*(n-1)*f*s2/(n-&p)/n); output;
  run;
proc gplot;
  axis1 length=4 in;
  axis2 length=6 in;
  plot ratio*variable / vaxis=axis1 haxis=axis2 vref=0 lvref=21; *reference now 0;
  symbol v=none i=hilot color=black;
  run;

title "Two sample Hotellings T2";
data swiss;
  infile "v:\505\datasets\swiss3.dat";
  input type $ length left right bottom top diag;
  run;
* hypothesis test for equal mean vectors;
proc iml;
  start hotel2;
    n1=nrow(x1);
    n2=nrow(x2);
    k=ncol(x1);
    one1=j(n1,1,1);
    one2=j(n2,1,1);
    ident1=i(n1);
    ident2=i(n2);
    xbar1=x1`*one1/n1;
    s1=x1`*(ident1-one1*one1`/n1)*x1/(n1-1.0);
    print n1 xbar1;
    print s1;
    xbar2=x2`*one2/n2;
    s2=x2`*(ident2-one2*one2`/n2)*x2/(n2-1.0);
    print n2 xbar2;
    print s2;
    spool=((n1-1.0)*s1+(n2-1.0)*s2)/(n1+n2-2.0);
    print spool;
    t2=(xbar1-xbar2)`*inv(spool*(1/n1+1/n2))*(xbar1-xbar2);
    f=(n1+n2-k-1)*t2/k/(n1+n2-2);
    df1=k;
    df2=n1+n2-k-1;
    p=1-probf(f,df1,df2);
    print t2 f df1 df2 p;
  finish;
  use swiss;
    read all var{length left right bottom top diag} where (type="real") into x1;
    read all var{length left right bottom top diag} where (type="fake") into x2;
  run hotel2;
  quit;

  * confidence intervals for the differences mu_1i - mu_2i;
%let p=6;
data real;
  set swiss;
  if type="real";
  variable="length";   x=length; output;
  variable="left";     x=left;   output;
  variable="right";    x=right;  output;
  variable="bottom";   x=bottom; output;
  variable="top";      x=top;    output;
  variable="diagonal"; x=diag;   output;
  keep type variable x;
  run;
proc sort;
  by variable;
  run;
proc means noprint;
  by variable;
  id type;
  var x;
  output out=pop1 n=n1 mean=xbar1 var=s21;
data fake;
  set swiss;
  if type="fake";
  variable="length";   x=length; output;
  variable="left";     x=left;   output;
  variable="right";    x=right;  output;
  variable="bottom";   x=bottom; output;
  variable="top";      x=top;    output;
  variable="diagonal"; x=diag;   output;
  keep type variable x;
  run;
proc sort;
  by variable;
  run;
proc means noprint;
  by variable;
  id type;
  var x;
  output out=pop2 n=n2 mean=xbar2 var=s22;
data combine;
  merge pop1 pop2;
  by variable;
  f=finv(0.95,&p,n1+n2-&p-1);
  t=tinv(1-0.025/&p,n1+n2-2);
  sp=((n1-1)*s21+(n2-1)*s22)/(n1+n2-2);
  losim=xbar1-xbar2-sqrt(&p*(n1+n2-2)*f*(1/n1+1/n2)*sp/(n1+n2-&p-1));
  upsim=xbar1-xbar2+sqrt(&p*(n1+n2-2)*f*(1/n1+1/n2)*sp/(n1+n2-&p-1));
  lobon=xbar1-xbar2-t*sqrt((1/n1+1/n2)*sp);
  upbon=xbar1-xbar2+t*sqrt((1/n1+1/n2)*sp);
  run;
proc print;
  var variable lobon upbon losim upsim;
  run;
