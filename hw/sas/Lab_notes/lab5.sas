* example for using iml to find conditional parameters;
proc iml;
* parameters for X;
mu_X = {-3,1,4};
sigma_X = {1 -2 0,-2 5 0,0 0 2};
A = {1 1 1,2 -1 -1,0 -1 1};
* parameters for Y = AX;
mu_Y = A*mu_X;
sigma_Y = A*sigma_X*t(A);
* partitioned parameters;
mu_Y1 = mu_Y[1];
mu_Y2 = mu_Y[2:3];
sigma_Y11 = sigma_Y[1,1];
sigma_Y12 = sigma_Y[1,2:3];
sigma_Y21 = t(sigma_Y12);
sigma_Y22 = sigma_Y[2:3,2:3];
* conditional parameters;
* mean is linear function of y2 with coefficients;
beta1 = sigma_Y12*inv(sigma_Y22);
beta0 = mu_Y1-beta1*mu_Y2;
beta = beta0||beta1;
var = sigma_Y11-sigma_Y12*inv(sigma_Y22)*sigma_Y21;
print beta var;
quit;

/* wechsler intelligence test data
   Id and 4 variables:
   Information (info)
   Similarities (sim)
   Arithmetic (arith)
   Picture Completion (pict) 

   The following considers the partial correlation 
   between info and sim, conditional on arith and pict
*/
data wechsler;
  infile 'v:\505\datasets\wechsler.dat';
  input id info sim arith pict;
  run;

* approach 1 (naive), finding the conditional distribution manually;
proc corr data=wechsler cov nocorr out=corr_out;
  var info sim arith pict;
  run;
proc iml;
  use corr_out;
  read all var _NUM_ where(_TYPE_="MEAN") into xbar[colname=varnames];
  read all var _NUM_ where(_TYPE_="COV") into S;
  read all var _NUM_ where(_TYPE_="N") into n;
  varnames=t(varNames);
  s2=vecdiag(S);
  n=n[1];
  xbar=t(xbar);
  xbar_1 = xbar[1:2];
  xbar_2 = xbar[3:4];
  S_11 = S[1:2,1:2];
  S_12 = S[1:2,3:4];
  S_21 = t(S_12);
  S_22 = S[3:4,3:4];
  b1 = s_12*inv(s_22);
  b0 = xbar_1-b1*xbar_2;
  b = b0||b1;
  cov = S_11-S_12*inv(S_22)*S_21;
  r = cov[1,2]/sqrt(cov[1,1]*cov[2,2]);
  print b cov r; *r is correct, but covariances are biased;
  quit;

* approach 2 (better), partial covariance matrix unbiased;
proc corr data=wechsler cov fisher(rho0=0 alpha=.05 biasadj=no);
  var info sim;
  partial arith pict;
  run;

* approach 3 (also fine), ;
proc glm data=wechsler;
model info sim = arith pict;
manova / printe; *prints sum of squares and cross-products matrix;
run;quit;

proc reg data=wechsler;
model info sim = arith pict;
run; quit;
