options ls=78;
/*
Data were collected on two species of insects: 'a' and 'b'
Three variables were measured on each insect:
  X1 = Width of the 1st joint of the tarsus (legs)
  X2 = Width of the 2nd joint of the tarsus
  X3 = Width of the aedeagus (sec organ)
We have ten individuals of each species to make up training data.
The goal is to classify the species for a specimen with x1=194 x2=124 x3=49
We also assume equal prior probabilities
*/
data insect;
  infile "v:\505\datasets\insect.dat";
  input species $ joint1 joint2 aedeagus;
  run;

*manual approach;
proc corr data=insect nocorr cov out=corr_out;
  by species;
  var joint1 joint2 aedeagus;
  run;
proc iml;
use corr_out;
  read all var _NUM_ where(_TYPE_="MEAN" & species='a') into xbar1;
  read all var _NUM_ where(_TYPE_="MEAN" & species='b') into xbar2;
  read all var _NUM_ where(_TYPE_="N" & species='a') into n1;
  read all var _NUM_ where(_TYPE_="N" & species='b') into n2;
  read all var _NUM_ where(_TYPE_="COV" & species='a') into S1;
  read all var _NUM_ where(_TYPE_="COV" & species='b') into S2;
  xbar1=t(xbar1);
  xbar2=t(xbar2);
  n1=n1[1];
  n2=n2[1];
  Sp=((n1-1)*S1+(n2-1)*S2)*(1/(n1+n2-2));
  x={194,124,49};
  print xbar1 x xbar2 Sp;
  *score values;
  p1=.5; 
  p2=.5; *(equal prior probabilities);
  *p1=.9; 
  *p2=.1; *(unequal prior probabilities);
  score_a = -1/2*t(xbar1)*inv(Sp)*xbar1+t(xbar1)*inv(Sp)*x+log(p1);
  score_b = -1/2*t(xbar2)*inv(Sp)*xbar2+t(xbar2)*inv(Sp)*x+log(p2);
  print score_a score_b;
  *posterior probabilities;
  postprob_a = exp(score_a)/(exp(score_a)+exp(score_b));
  postprob_b = 1-postprob_a;
  print postprob_a postprob_b;
  quit;

*using SAS discriminant procedure (equal priors default);
data test;
  input joint1 joint2 aedeagus;
  cards;
  194 124 49
  ; run;
proc discrim data=insect pool=test crossvalidate testdata=test testout=a;
  class species;
  var joint1 joint2 aedeagus;
  run;
proc print data=a;
  run;

*unequal priors;
data test;
  input joint1 joint2 aedeagus;
  cards;
  194 124 49
  ; run;
proc discrim data=insect pool=test crossvalidate testdata=test testout=b;
  class species;
  var joint1 joint2 aedeagus;
  priors 'a'=.9 'b'=.1;
  run;
proc print data=b;
  run;

*unequal covariances;
data swiss;
  infile "v:\505\datasets\swiss3.dat";
  input type $ length left right bottom top diag;
  run;
data test2;
  input length left right bottom top diag;
  cards;
  214.9 130.1 129.9 9 10.6 140.5
  ; run;
proc discrim data=swiss pool=test crossvalidate testdata=test2 testout=c;
  class type;
  var length left right bottom top diag;
  priors "real"=0.99 "fake"=0.01;
  run;
proc print data=c;
  run;
