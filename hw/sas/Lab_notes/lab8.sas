/*
g = 4 treatment groups:
  1 = Control - no surgical treatment is applied
  2 = Extrinsic cardiac denervation immediately prior to treatment.
  3 = Bilateral thoracic sympathectomy and stellectomy 3 weeks prior to treatment.
  4 = Extrinsic cardiac denervation 3 weeks prior to treatment.

p = 4 potassium levels measured at 1, 5, 9, and 13 minutes following a procedure
n = 9 dogs with each treatment
*/
data dogs;
  infile 'v:\505\datasets\dog1.dat';
  input treat dog p1 p2 p3 p4;
  i1=p1-p2; i2=p2-p3; i3=p3-p4;
  m=p1+p2+p3+p4;
  run;
data dogs2;
  set dogs;
  time=1;  k=p1; output;
  time=5;  k=p2; output;
  time=9;  k=p3; output;
  time=13; k=p4; output;
  drop p1 p2 p3 p4;
  run;
*profile plots;
proc sort data=dogs2;
  by treat time;
  run;
proc means data=dogs2;
  by treat time;
  var k;
  output out=a mean=mean;
  run;
goptions device=ps300 gsfname=t1 gsfmode=replace;
proc gplot data=a;
  axis1 length=4 in;
  axis2 length=6 in;
  plot mean*time=treat / vaxis=axis1 haxis=axis2;
  symbol1 v=J f=special h=2 i=join color=black;
  symbol2 v=K f=special h=2 i=join color=black;
  symbol3 v=L f=special h=2 i=join color=black;
  symbol4 v=M f=special h=2 i=join color=black;
  run;

*manova approach;
*test for interaction with contrasts;
proc glm data=dogs;
  class treat;
  model p1 p2 p3 p4=treat;
  *model i1 i2 i3=treat; *may use these instead of specifying m below;

  *contrast '1 vs 234' treat 3 -1 -1 -1;
  *contrast '2 vs 3' treat 0 1 -1 0;
  *contrast '3 vs 4' treat 0 0 1 -1;
  *contrast '234' treat 0 2 -1 -1, treat 0 0 1 -1;
  
  manova h=treat m=p1-p2,p2-p3,p3-p4 / printh printe;
  *manova h=treat; *test of equal mean vectors, equivalent to m=p1,p2,p3,p4;
  run; quit;

*test for main effect with contrasts;
proc glm data=dogs;
  class treat;
  model p1 p2 p3 p4=treat;
  *model m=treat; *may use this instead of specifying m below;

  contrast '1 vs 234' treat 3 -1 -1 -1;
  contrast '2 vs 3' treat 0 1 -1 0;
  contrast '3 vs 4' treat 0 0 1 -1;
  contrast '234' treat 0 2 -1 -1, treat 0 0 1 -1;
    
  manova h=treat m=p1+p2+p3+p4 / printh printe; *test of main effects, summing over times;
  run; quit;

*test for time effect;
proc glm data=dogs;
  class treat;
  model p1 p2 p3 p4=treat;
  repeated time 4 /printe;
  run; quit;

*random effects approach;
*split plot model;
proc mixed data=dogs2;
  class treat dog time;
  model k=treat|time;
  random dog(treat);
  run;
*autoregressive model;
proc mixed data=dogs2;
  class treat dog time;
  model k=treat|time;
  random dog(treat);
  repeated / subject=dog(treat) type=ar(1);
  run;
*autoregressive + moving averages model;
proc mixed data=dogs2;
  class treat dog time;
  model k=treat|time;
  random dog(treat);
  repeated / subject=dog(treat) type=arma(1,1);
  run;
*toeplitz model;
proc mixed data=dogs2;
  class treat dog time;
  model k=treat|time;
  random dog(treat) ;
  repeated / subject=dog(treat) type=toep;
  run;


